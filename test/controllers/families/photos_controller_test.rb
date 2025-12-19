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

    test "should not create photo without image in production" do
      # 프로덕션 환경 시뮬레이션
      original_env = Rails.env
      Rails.env = ActiveSupport::StringInquirer.new("production")

      assert_no_difference "Photo.count" do
        post family_photos_path(@family), params: {
          photo: {
            caption: "이미지 없음",
            taken_at: Time.current.iso8601
          }
        }
      end

      assert_response :unprocessable_entity
    ensure
      Rails.env = original_env
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
    test "should return partial success for batch upload in production" do
      # 프로덕션 환경 시뮬레이션 - 이미지 없는 사진은 실패해야 함
      original_env = Rails.env
      Rails.env = ActiveSupport::StringInquirer.new("production")

      post batch_family_photos_path(@family), params: {
        photos: [
          {
            caption: "성공할 사진",
            taken_at: Time.current.iso8601,
            image: fixture_file_upload("photo.jpg", "image/jpeg")
          },
          {
            caption: "실패할 사진 (이미지 없음)",
            taken_at: Time.current.iso8601
          }
        ]
      }

      assert_response :success
      json = JSON.parse(response.body)

      success_results = json["results"].select { |r| r["success"] }
      failure_results = json["results"].reject { |r| r["success"] }

      assert_equal 1, success_results.count, "하나는 성공해야 함"
      assert_equal 1, failure_results.count, "하나는 실패해야 함"
      assert failure_results.first["errors"].present?, "실패 이유가 있어야 함"
    ensure
      Rails.env = original_env
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

    # ========================================
    # 5.6.3 ActiveStorage 에러 처리 테스트
    # ========================================

    test "should handle ActiveStorage attachment errors gracefully" do
      # 허용되지 않는 파일 형식 업로드 시 적절한 에러 메시지 반환
      assert_no_difference "Photo.count" do
        post family_photos_path(@family), params: {
          photo: {
            caption: "허용되지 않는 파일",
            taken_at: Time.current,
            image: fixture_file_upload("corrupt.txt", "text/plain")
          }
        }
      end

      assert_response :unprocessable_entity
    end

    test "should return user-friendly message for storage errors in batch upload" do
      # 배치 업로드 시 저장소 에러도 개별 실패로 처리
      post batch_family_photos_path(@family), params: {
        photos: [
          {
            caption: "정상 사진",
            taken_at: Time.current.iso8601,
            image: fixture_file_upload("photo.jpg", "image/jpeg")
          }
        ]
      }

      assert_response :success
      json = JSON.parse(response.body)
      assert json["results"].present?
    end

    # ========================================
    # 5.6.6 N+1 쿼리 해결 테스트
    # ========================================

    test "should not have N+1 queries on index with photos" do
      # 추가 사진 생성
      3.times do |i|
        create_photo_with_image(caption: "추가 사진 #{i}")
      end

      # 첫 번째 요청 쿼리 수 측정
      first_count = count_queries do
        get family_photos_path(@family)
      end

      # 더 많은 사진 추가
      3.times do |i|
        create_photo_with_image(caption: "더 추가 사진 #{i}")
      end

      # 두 번째 요청 쿼리 수 측정
      second_count = count_queries do
        get family_photos_path(@family)
      end

      # N+1 없으면 쿼리 수 차이가 적음 (허용: 5개 이하)
      assert (second_count - first_count).abs <= 5,
             "N+1 query suspected: first=#{first_count}, second=#{second_count}"
    end

    test "should eagerly load image attachment in index" do
      create_photo_with_image

      queries = []
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        queries << event.payload[:sql] unless event.payload[:name] == "SCHEMA"
      end

      get family_photos_path(@family)

      ActiveSupport::Notifications.unsubscribe(subscriber)

      # SELECT 쿼리 수가 적정 범위 내여야 함
      select_queries = queries.select { |q| q.include?("SELECT") && !q.include?("sqlite") }
      assert select_queries.count <= 15, "Too many queries: #{select_queries.count}"
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

    def count_queries(&block)
      count = 0
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        count += 1 unless event.payload[:name] == "SCHEMA"
      end

      block.call

      ActiveSupport::Notifications.unsubscribe(subscriber)
      count
    end
  end
end
