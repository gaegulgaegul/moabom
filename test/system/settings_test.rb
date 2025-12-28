# frozen_string_literal: true

require "application_system_test_case"

class SettingsTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    sign_in @user
  end

  # 7.1 설정 메인 페이지 테스트
  test "설정 페이지 접근" do
    visit settings_profile_path

    # 페이지 제목 확인
    assert_selector "h1", text: "설정"
  end

  test "계정 설정 섹션 표시" do
    visit settings_profile_path

    # Sketch CardComponent 확인
    assert_selector ".bg-sketch-paper.border-2"

    # 프로필 설정 링크
    assert_text "프로필 설정"

    # 알림 설정 링크
    assert_text "알림 설정"

    # 다크 모드 토글
    assert_text "다크 모드"
    assert_selector "button[data-controller='toggle']"
  end

  test "프로필 수정 폼 표시" do
    visit settings_profile_path

    # 프로필 정보 섹션
    assert_selector "h2", text: "프로필 정보"

    # 이메일 필드 (비활성화)
    assert_selector "input[type='email'][disabled]"
    assert_text "이메일은 변경할 수 없습니다"

    # 닉네임 필드
    assert_selector "input[name='user[nickname]']"
  end

  test "정보 섹션 표시" do
    visit settings_profile_path

    # 이용약관
    assert_text "이용약관"

    # 개인정보 처리방침
    assert_text "개인정보 처리방침"

    # 앱 정보
    assert_text "앱 정보"
    assert_text "v1.0.0"
  end

  test "로그아웃 버튼 표시" do
    visit settings_profile_path

    # 로그아웃 텍스트
    assert_selector ".text-red-500", text: "로그아웃"
  end

  test "프로필 수정 기능" do
    visit settings_profile_path

    # 닉네임 변경
    fill_in "user[nickname]", with: "새로운닉네임"
    click_on "저장"

    # 성공 메시지 확인
    assert_text "프로필이 업데이트되었습니다"

    # 변경된 닉네임 확인
    @user.reload
    assert_equal "새로운닉네임", @user.nickname
  end

  test "알림 설정 페이지로 이동" do
    visit settings_profile_path

    # 알림 설정 링크 클릭
    click_on "알림 설정"

    # 알림 설정 페이지로 이동 확인
    assert_current_path settings_notifications_path
  end

  # 7.2 알림 설정 페이지 테스트
  test "알림 설정 페이지 접근" do
    visit settings_notifications_path

    # 페이지 제목 확인
    assert_selector "h1", text: "알림 설정"
  end

  test "알림 설정 목록 표시" do
    visit settings_notifications_path

    # 알림 설정 카드 (Sketch CardComponent)
    assert_selector ".bg-sketch-paper.border-2"

    # 새 사진 알림
    assert_text "새 사진 알림"
    assert_text "가족이 새 사진을 올리면 알려드려요"

    # 댓글 알림
    assert_text "댓글 알림"
    assert_text "내 사진에 댓글이 달리면 알려드려요"

    # 반응 알림
    assert_text "반응 알림"
    assert_text "내 사진에 반응이 달리면 알려드려요"

    # 가족 초대 알림
    assert_text "가족 초대 알림"
    assert_text "새 가족이 참여하면 알려드려요"
  end

  test "디자인 시스템 준수 - Sketch CardComponent 사용" do
    visit settings_profile_path

    # Sketch CardComponent 사용 확인 (bg-sketch-paper border-2)
    assert_selector ".bg-sketch-paper.border-2", minimum: 3
  end

  test "디자인 시스템 준수 - lucide 아이콘 사용" do
    visit settings_profile_path

    # SVG 아이콘 확인 (lucide)
    assert_selector "svg", minimum: 5
  end
end
