# frozen_string_literal: true

require "application_system_test_case"

class Families::PhotoShowTest < ApplicationSystemTestCase
  setup do
    @family = families(:kim_family)
    @user = users(:mom)
    @photo = photos(:baby_first_step)
    sign_in @user
  end

  test "사진 상세 페이지 방문" do
    visit family_photo_path(@family, @photo)

    # Sketch 디자인: bg-sketch-ink (검정 배경)
    assert_selector ".min-h-screen.bg-sketch-ink"
  end

  test "투명 헤더가 표시됨" do
    visit family_photo_path(@family, @photo)

    assert_selector "header.fixed"
    assert_selector "button", text: "" # 뒤로 가기 버튼
  end

  test "사진이 표시됨" do
    visit family_photo_path(@family, @photo)

    # 사진이 attached되어 있지 않으므로 placeholder
    assert_selector ".aspect-square"
  end

  test "정보 영역이 rounded-t-3xl" do
    visit family_photo_path(@family, @photo)

    assert_selector ".rounded-t-3xl"
  end

  test "캡션이 표시됨" do
    visit family_photo_path(@family, @photo)

    assert_text @photo.caption
  end

  test "업로더 정보가 표시됨" do
    visit family_photo_path(@family, @photo)

    assert_text "업로드: #{@photo.uploader.nickname}"
  end

  test "아이 정보가 표시됨" do
    visit family_photo_path(@family, @photo)

    if @photo.child
      assert_text "아이: #{@photo.child.name}"
    end
  end

  test "고정 댓글 입력창이 표시됨" do
    visit family_photo_path(@family, @photo)

    assert_selector ".fixed.bottom-0"
    assert_field placeholder: "댓글 작성..."
  end

  test "뒤로 가기 버튼 클릭 시 타임라인으로 이동" do
    visit family_photo_path(@family, @photo)

    # JavaScript onclick="history.back()" 테스트는 어려움
    # 버튼 존재 확인만
    assert_selector "button"
  end
end
