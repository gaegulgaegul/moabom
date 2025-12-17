# frozen_string_literal: true

require "application_system_test_case"

class Families::PhotoUploadTest < ApplicationSystemTestCase
  setup do
    @family = families(:kim_family)
    @user = users(:mom)
    sign_in @user
  end

  test "업로드 페이지 방문" do
    visit new_family_photo_path(@family)

    assert_text "사진 업로드"
  end

  test "취소/완료 헤더가 표시됨" do
    visit new_family_photo_path(@family)

    assert_link "취소"
    assert_button "완료"
  end

  test "이미지 미리보기 영역 표시" do
    visit new_family_photo_path(@family)

    assert_selector ".aspect-square"
    assert_text "사진을 선택해주세요"
  end

  test "캡션 입력 필드 표시" do
    visit new_family_photo_path(@family)

    assert_selector "textarea[placeholder='이 순간에 대해 적어보세요...']"
  end

  test "아이 태그 pill 버튼 표시" do
    visit new_family_photo_path(@family)

    assert_selector "button[type='button']", text: "전체"

    if @family.children.any?
      child = @family.children.first
      assert_selector "button[type='button']", text: child.name
    end
  end

  test "촬영일 입력 필드 표시" do
    visit new_family_photo_path(@family)

    assert_selector "input[type='date']"
  end

  test "pill 버튼 스타일 확인" do
    visit new_family_photo_path(@family)

    # 전체 버튼이 활성 상태 (bg-primary-500)
    assert_selector "button.bg-primary-500", text: "전체"
  end

  test "input-textarea 스타일 확인" do
    visit new_family_photo_path(@family)

    # h-24 클래스 확인
    assert_selector "textarea.h-24"
  end
end
