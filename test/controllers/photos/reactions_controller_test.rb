# frozen_string_literal: true

require "test_helper"

module Photos
  class ReactionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      @family = families(:kim_family)
      @photo = create_photo_with_image
      post login_path, params: { user_id: @user.id }
    end

    # ========================================
    # 반응 추가 테스트
    # ========================================

    test "should create reaction" do
      assert_difference "Reaction.count", 1 do
        post family_photo_reactions_path(@family, @photo), params: {
          reaction: { emoji: "❤️" }
        }
      end

      assert_redirected_to family_photo_path(@family, @photo)
      reaction = Reaction.last
      assert_equal "❤️", reaction.emoji
      assert_equal @user, reaction.user
      assert_equal @photo, reaction.photo
    end

    test "should return turbo stream for create" do
      post family_photo_reactions_path(@family, @photo), params: {
        reaction: { emoji: "😍" }
      }, as: :turbo_stream

      assert_response :success
      assert_match "turbo-stream", response.content_type
    end

    test "should return json for create" do
      post family_photo_reactions_path(@family, @photo), params: {
        reaction: { emoji: "👍" }
      }, as: :json

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal "👍", json["emoji"]
    end

    # ========================================
    # 반응 변경 테스트
    # ========================================

    test "should change reaction emoji" do
      reaction = @photo.reactions.create!(user: @user, emoji: "❤️")

      post family_photo_reactions_path(@family, @photo), params: {
        reaction: { emoji: "😍" }
      }

      assert_redirected_to family_photo_path(@family, @photo)
      assert_equal "😍", reaction.reload.emoji
      # 새로운 반응이 생성되지 않고 기존 반응이 업데이트됨
      assert_equal 1, @photo.reactions.where(user: @user).count
    end

    # ========================================
    # 반응 삭제 테스트
    # ========================================

    test "should delete reaction" do
      reaction = @photo.reactions.create!(user: @user, emoji: "❤️")

      assert_difference "Reaction.count", -1 do
        delete family_photo_reaction_path(@family, @photo, reaction)
      end

      assert_redirected_to family_photo_path(@family, @photo)
    end

    test "should not delete other user reaction" do
      other_user = users(:dad)
      reaction = @photo.reactions.create!(user: other_user, emoji: "❤️")

      assert_no_difference "Reaction.count" do
        delete family_photo_reaction_path(@family, @photo, reaction)
      end

      # 권한 없음 처리
      assert_response :forbidden
    end

    # ========================================
    # 6.5.4: 잘못된 이모지 입력 처리
    # ========================================

    test "should reject invalid emoji with html format" do
      assert_no_difference "Reaction.count" do
        post family_photo_reactions_path(@family, @photo), params: {
          reaction: { emoji: "invalid" }
        }
      end

      assert_redirected_to family_photo_path(@family, @photo)
      assert flash[:alert].present?, "에러 메시지가 있어야 함"
    end

    test "should reject invalid emoji with json format" do
      post family_photo_reactions_path(@family, @photo), params: {
        reaction: { emoji: "🚫" }
      }, as: :json

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert json["errors"].present?
    end

    # ========================================
    # 인증 테스트
    # ========================================

    test "should require authentication for create" do
      delete logout_path
      post family_photo_reactions_path(@family, @photo), params: {
        reaction: { emoji: "❤️" }
      }

      assert_redirected_to root_path
    end

    test "should require authentication for delete" do
      reaction = @photo.reactions.create!(user: @user, emoji: "❤️")
      delete logout_path

      delete family_photo_reaction_path(@family, @photo, reaction)

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
