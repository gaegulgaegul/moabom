# frozen_string_literal: true

require "test_helper"

module Photos
  class CommentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      @family = families(:kim_family)
      @photo = create_photo_with_image
      post login_path, params: { user_id: @user.id }
    end

    # ========================================
    # 댓글 목록 테스트
    # ========================================

    test "should return comments list" do
      @photo.comments.create!(user: @user, body: "첫 번째 댓글")
      @photo.comments.create!(user: users(:dad), body: "두 번째 댓글")

      get family_photo_comments_path(@family, @photo), as: :json

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json["data"].length
    end

    # ========================================
    # 댓글 추가 테스트
    # ========================================

    test "should create comment" do
      assert_difference "Comment.count", 1 do
        post family_photo_comments_path(@family, @photo), params: {
          comment: { body: "멋진 사진이네요!" }
        }
      end

      assert_redirected_to family_photo_path(@family, @photo)
      comment = Comment.last
      assert_equal "멋진 사진이네요!", comment.body
      assert_equal @user, comment.user
      assert_equal @photo, comment.photo
    end

    test "should return turbo stream for create" do
      post family_photo_comments_path(@family, @photo), params: {
        comment: { body: "좋아요!" }
      }, as: :turbo_stream

      assert_response :success
      assert_match "turbo-stream", response.content_type
    end

    test "should return json for create" do
      post family_photo_comments_path(@family, @photo), params: {
        comment: { body: "JSON 댓글" }
      }, as: :json

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal "JSON 댓글", json["body"]
    end

    test "should not create comment with blank body" do
      assert_no_difference "Comment.count" do
        post family_photo_comments_path(@family, @photo), params: {
          comment: { body: "" }
        }, as: :json
      end

      assert_response :unprocessable_entity
    end

    # ========================================
    # 6.5.5: 긴 댓글 입력 처리
    # ========================================

    test "should reject comment exceeding max length with html format" do
      long_body = "가" * 1001
      assert_no_difference "Comment.count" do
        post family_photo_comments_path(@family, @photo), params: {
          comment: { body: long_body }
        }
      end

      assert_redirected_to family_photo_path(@family, @photo)
      assert flash[:alert].present?, "에러 메시지가 있어야 함"
    end

    test "should reject comment exceeding max length with json format" do
      long_body = "가" * 1001
      post family_photo_comments_path(@family, @photo), params: {
        comment: { body: long_body }
      }, as: :json

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert json["errors"].present?
    end

    # ========================================
    # 댓글 삭제 테스트
    # ========================================

    test "should delete own comment" do
      comment = @photo.comments.create!(user: @user, body: "삭제할 댓글")

      assert_difference "Comment.count", -1 do
        delete family_photo_comment_path(@family, @photo, comment)
      end

      assert_redirected_to family_photo_path(@family, @photo)
    end

    test "should not delete other user comment" do
      other_user = users(:dad)
      comment = @photo.comments.create!(user: other_user, body: "다른 사람 댓글")

      assert_no_difference "Comment.count" do
        delete family_photo_comment_path(@family, @photo, comment)
      end

      assert_response :forbidden
    end

    # ========================================
    # 인증 테스트
    # ========================================

    test "should require authentication for index" do
      delete logout_path

      get family_photo_comments_path(@family, @photo)

      assert_redirected_to root_path
    end

    test "should require authentication for create" do
      delete logout_path

      post family_photo_comments_path(@family, @photo), params: {
        comment: { body: "인증 없는 댓글" }
      }

      assert_redirected_to root_path
    end

    test "should require authentication for delete" do
      comment = @photo.comments.create!(user: @user, body: "삭제할 댓글")
      delete logout_path

      delete family_photo_comment_path(@family, @photo, comment)

      assert_redirected_to root_path
    end

    private

    def create_photo_with_image
      photo = @family.photos.build(
        uploader: @user,
        caption: "테스트 사진",
        taken_at: Time.current
      )
      photo.image.attach(
        io: StringIO.new("fake image data"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
      photo.save!
      photo
    end
  end
end
