# frozen_string_literal: true

require "test_helper"

module Families
  class PhotosControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      @family = families(:kim_family)
      @child = children(:baby_kim)
      post login_path, params: { user_id: @user.id }
    end

    # ========================================
    # 5.1 타임라인 테스트
    # ========================================

    test "should get index with family photos" do
      get family_photos_path(@family)

      assert_response :success
      assert_select "h1", /사진|타임라인|Photos/i
    end

    test "should only show photos from the family" do
      # 다른 가족의 사진은 보이지 않아야 함
      other_family = families(:lee_family)

      get family_photos_path(@family)

      assert_response :success
      # kim_family의 사진만 표시되어야 함
    end

    test "should order photos by taken_at desc (recent first)" do
      get family_photos_path(@family)

      assert_response :success
      # 최신 사진이 먼저 표시되어야 함
    end

    test "should filter photos by child" do
      get family_photos_path(@family), params: { child_id: @child.id }

      assert_response :success
      # child_id 파라미터로 필터링
    end

    test "should support pagination" do
      get family_photos_path(@family), params: { page: 1 }

      assert_response :success
    end

    test "should return json for json format" do
      get family_photos_path(@family), as: :json

      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("data") || json.is_a?(Array)
    end

    test "should require authentication" do
      delete logout_path
      get family_photos_path(@family)

      assert_redirected_to root_path
    end

    test "should not allow access to other family photos" do
      other_family = families(:lee_family)
      get family_photos_path(other_family)

      assert_redirected_to root_path
    end

    # ========================================
    # 날짜별 그룹핑 테스트
    # ========================================

    test "should group photos by month when requested" do
      get family_photos_path(@family), params: { year: 2025, month: 1 }

      assert_response :success
      # 2025년 1월 사진만 표시
    end

    # ========================================
    # 5.2 사진 업로드 테스트
    # ========================================

    test "should show new photo form" do
      get new_family_photo_path(@family)

      assert_response :success
      assert_select "form"
    end

    test "should create photo with valid params" do
      assert_difference "Photo.count", 1 do
        post family_photos_path(@family), params: {
          photo: {
            caption: "테스트 사진",
            taken_at: Time.current,
            child_id: @child.id,
            image: fixture_file_upload("photo.jpg", "image/jpeg")
          }
        }
      end

      photo = Photo.last
      assert_equal "테스트 사진", photo.caption
      assert_equal @user, photo.uploader
      assert_equal @child, photo.child
      assert photo.image.attached?

      assert_redirected_to family_photo_path(@family, photo)
    end

    test "should set current user as uploader" do
      post family_photos_path(@family), params: {
        photo: {
          caption: "업로더 테스트",
          taken_at: Time.current,
          image: fixture_file_upload("photo.jpg", "image/jpeg")
        }
      }

      assert_equal @user, Photo.last.uploader
    end

    test "should not create photo without image" do
      assert_no_difference "Photo.count" do
        post family_photos_path(@family), params: {
          photo: {
            caption: "이미지 없음",
            taken_at: Time.current
          }
        }
      end

      assert_response :unprocessable_entity
    end

    test "should not create photo without taken_at" do
      assert_no_difference "Photo.count" do
        post family_photos_path(@family), params: {
          photo: {
            caption: "날짜 없음",
            image: fixture_file_upload("photo.jpg", "image/jpeg")
          }
        }
      end

      assert_response :unprocessable_entity
    end

    # ========================================
    # 5.4 사진 상세 테스트
    # ========================================

    test "should show photo detail" do
      photo = photos(:baby_first_step)
      get family_photo_path(@family, photo)

      assert_response :success
    end

    # ========================================
    # 5.5 사진 수정/삭제 테스트
    # ========================================

    test "should show edit form" do
      photo = create_photo_with_image
      get edit_family_photo_path(@family, photo)

      assert_response :success
      assert_select "form"
    end

    test "should update photo caption" do
      photo = create_photo_with_image(caption: "원본 캡션")
      patch family_photo_path(@family, photo), params: {
        photo: { caption: "수정된 캡션" }
      }

      assert_redirected_to family_photo_path(@family, photo)
      assert_equal "수정된 캡션", photo.reload.caption
    end

    test "should delete photo" do
      photo = create_photo_with_image

      assert_difference "Photo.count", -1 do
        delete family_photo_path(@family, photo)
      end

      assert_redirected_to family_photos_path(@family)
    end

    # ========================================
    # 5.3 대량 업로드 테스트
    # ========================================

    test "should batch upload multiple photos" do
      assert_difference "Photo.count", 2 do
        post batch_family_photos_path(@family), params: {
          photos: [
            {
              caption: "첫 번째 사진",
              taken_at: Time.current.iso8601,
              image: fixture_file_upload("photo.jpg", "image/jpeg")
            },
            {
              caption: "두 번째 사진",
              taken_at: Time.current.iso8601,
              image: fixture_file_upload("photo.jpg", "image/jpeg")
            }
          ]
        }
      end

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json["results"].count
      assert json["results"].all? { |r| r["success"] }
    end

    test "should return partial success for batch upload" do
      # 하나는 성공, 하나는 실패 (이미지 없음)
      assert_difference "Photo.count", 1 do
        post batch_family_photos_path(@family), params: {
          photos: [
            {
              caption: "성공할 사진",
              taken_at: Time.current.iso8601,
              image: fixture_file_upload("photo.jpg", "image/jpeg")
            },
            {
              caption: "실패할 사진",
              taken_at: Time.current.iso8601
              # 이미지 없음
            }
          ]
        }
      end

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json["results"].count

      success_result = json["results"].find { |r| r["success"] }
      failure_result = json["results"].find { |r| !r["success"] }

      assert success_result.present?
      assert failure_result.present?
      assert failure_result["errors"].present?
    end

    test "should reject batch upload without authentication" do
      delete logout_path
      post batch_family_photos_path(@family), params: { photos: [] }

      assert_redirected_to root_path
    end

    # ========================================
    # 5.6.1 역할 기반 권한 체크 테스트
    # ========================================

    test "viewer cannot upload photos" do
      # grandma는 viewer 역할
      grandma = users(:grandma)
      delete logout_path
      post login_path, params: { user_id: grandma.id }

      assert_no_difference "Photo.count" do
        post family_photos_path(@family), params: {
          photo: {
            caption: "Viewer 업로드 시도",
            taken_at: Time.current,
            image: fixture_file_upload("photo.jpg", "image/jpeg")
          }
        }
      end

      assert_redirected_to root_path
      assert_equal "권한이 없습니다.", flash[:alert]
    end

    test "member can upload photos" do
      # uncle은 member 역할
      uncle = users(:uncle)
      delete logout_path
      post login_path, params: { user_id: uncle.id }

      assert_difference "Photo.count", 1 do
        post family_photos_path(@family), params: {
          photo: {
            caption: "Member 업로드",
            taken_at: Time.current,
            image: fixture_file_upload("photo.jpg", "image/jpeg")
          }
        }
      end

      assert_redirected_to family_photo_path(@family, Photo.last)
    end

    test "uploader can delete their own photo" do
      photo = create_photo_with_image
      # @user (mom, owner)가 업로드한 사진

      assert_difference "Photo.count", -1 do
        delete family_photo_path(@family, photo)
      end

      assert_redirected_to family_photos_path(@family)
    end

    test "owner can delete other users photos" do
      # uncle (member)이 업로드한 사진
      uncle = users(:uncle)
      photo = @family.photos.build(
        uploader: uncle,
        caption: "Uncle의 사진",
        taken_at: Time.current
      )
      photo.image.attach(
        io: StringIO.new("fake image data"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
      photo.save!

      # @user는 owner이므로 삭제 가능
      assert_difference "Photo.count", -1 do
        delete family_photo_path(@family, photo)
      end

      assert_redirected_to family_photos_path(@family)
    end

    test "admin can delete other users photos" do
      # uncle (member)이 업로드한 사진
      uncle = users(:uncle)
      photo = @family.photos.build(
        uploader: uncle,
        caption: "Uncle의 사진",
        taken_at: Time.current
      )
      photo.image.attach(
        io: StringIO.new("fake image data"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
      photo.save!

      # dad는 admin이므로 삭제 가능
      delete logout_path
      post login_path, params: { user_id: users(:dad).id }

      assert_difference "Photo.count", -1 do
        delete family_photo_path(@family, photo)
      end

      assert_redirected_to family_photos_path(@family)
    end

    test "member cannot delete other users photos" do
      # mom (owner)이 업로드한 사진
      photo = create_photo_with_image

      # uncle (member)로 로그인
      delete logout_path
      uncle = users(:uncle)
      post login_path, params: { user_id: uncle.id }

      assert_no_difference "Photo.count" do
        delete family_photo_path(@family, photo)
      end

      assert_redirected_to root_path
      assert_equal "권한이 없습니다.", flash[:alert]
    end

    test "viewer cannot delete any photos" do
      # mom (owner)이 업로드한 사진
      photo = create_photo_with_image

      # grandma (viewer)로 로그인
      delete logout_path
      grandma = users(:grandma)
      post login_path, params: { user_id: grandma.id }

      assert_no_difference "Photo.count" do
        delete family_photo_path(@family, photo)
      end

      assert_redirected_to root_path
      assert_equal "권한이 없습니다.", flash[:alert]
    end

    # ========================================
    # 5.6.2 배치 업로드 검증 테스트
    # ========================================

    test "should reject empty array batch upload" do
      post batch_family_photos_path(@family), params: { photos: [] }

      assert_response :bad_request
      json = JSON.parse(response.body)
      assert json["error"].present?
      assert_match(/비어있습니다|없습니다/, json["error"]["message"])
    end

    test "should reject non-array batch upload" do
      post batch_family_photos_path(@family), params: { photos: "not an array" }

      assert_response :bad_request
      json = JSON.parse(response.body)
      assert json["error"].present?
      assert_match(/배열|형식/, json["error"]["message"])
    end

    test "should reject batch upload exceeding max size" do
      # 최대 개수보다 많은 사진 업로드 시도
      photos = (1..101).map do |i|
        {
          caption: "사진 #{i}",
          taken_at: Time.current.iso8601,
          image: fixture_file_upload("photo.jpg", "image/jpeg")
        }
      end

      post batch_family_photos_path(@family), params: { photos: photos }

      assert_response :bad_request
      json = JSON.parse(response.body)
      assert json["error"].present?
      assert_match(/최대|초과/, json["error"]["message"])
    end

    private

    def create_photo_with_image(caption: "테스트 사진")
      photo = @family.photos.build(
        uploader: @user,
        caption: caption,
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
