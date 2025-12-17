# frozen_string_literal: true

require "test_helper"

class UiStatesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    post login_path, params: { user_id: @user.id }
  end

  # ========================================
  # 9.2 빈 상태 및 에러 페이지 테스트
  # ========================================

  test "photos index should show empty state when no photos" do
    # 기존 사진 삭제
    @family.photos.destroy_all

    get family_photos_path(@family)

    assert_response :success
    # 빈 상태 메시지와 CTA 버튼
    assert_select "[class*='empty-state']" do
      assert_select "h3", /사진이 없|아직 사진이 없어요/
      assert_select "a[href*='new']", /업로드|첫 사진/
    end
  end

  test "404 error page should have user-friendly design" do
    # 존재하지 않는 사진 접근 시 404 페이지
    get family_photo_path(@family, id: 88888)

    assert_response :not_found
    assert_select "h1", /찾을 수 없/
  end

  test "photo 404 should show friendly error" do
    get family_photo_path(@family, id: 99999)

    assert_response :not_found
    assert_select "h1", /찾을 수 없|존재하지 않/
  end

  # ========================================
  # 9.3 반응형 디자인 테스트
  # ========================================

  test "main layout should have responsive classes" do
    get family_photos_path(@family)

    assert_response :success
    # 반응형 패딩/여백 클래스
    assert_select "[class*='px-']"
    # 반응형 그리드나 flex 클래스
    assert_select "[class*='grid']"
  end

  test "navigation should be responsive" do
    get family_photos_path(@family)

    assert_response :success
    # 네비게이션 요소에 반응형 클래스
    assert_select "nav" do
      assert_select "[class*='flex']"
    end
  end
end
