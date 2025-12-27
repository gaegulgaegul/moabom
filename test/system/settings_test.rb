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

    # 계정 설정 카드
    assert_selector ".card-solid"

    # 프로필 설정 링크
    within ".card-solid", match: :first do
      assert_selector "svg"  # lucide user-circle
      assert_text "프로필 설정"
      assert_selector "svg"  # lucide chevron-right
    end

    # 알림 설정 링크
    within ".card-solid", match: :first do
      assert_selector "svg"  # lucide bell
      assert_text "알림 설정"
    end

    # 다크 모드 토글
    within ".card-solid", match: :first do
      assert_selector "svg"  # lucide moon
      assert_text "다크 모드"
      assert_selector "button[data-controller='toggle']"
    end
  end

  test "프로필 수정 폼 표시" do
    visit settings_profile_path

    # 프로필 정보 섹션
    assert_selector "h2", text: "프로필 정보"

    # 이메일 필드 (비활성화)
    assert_selector "label", text: "이메일"
    assert_selector "input[type='email'][disabled]"
    assert_text "이메일은 변경할 수 없습니다"

    # 닉네임 필드
    assert_selector "label", text: "닉네임"
    assert_selector "input[type='text'][name='user[nickname]']"

    # 저장 버튼
    assert_selector "input[type='submit'][value='저장']"
  end

  test "정보 섹션 표시" do
    visit settings_profile_path

    # 정보 섹션 카드
    within all(".card-solid")[2] do
      # 이용약관
      assert_selector "svg"  # lucide document-text
      assert_text "이용약관"

      # 개인정보 처리방침
      assert_selector "svg"  # lucide shield-check
      assert_text "개인정보 처리방침"

      # 앱 정보
      assert_selector "svg"  # lucide information-circle
      assert_text "앱 정보"
      assert_text "v1.0.0"
    end
  end

  test "로그아웃 버튼 표시" do
    visit settings_profile_path

    # 로그아웃 카드
    within all(".card-solid").last do
      assert_selector "svg"  # lucide arrow-right-on-rectangle
      assert_selector ".text-red-500", text: "로그아웃"
    end
  end

  test "프로필 수정 기능" do
    visit settings_profile_path

    # 닉네임 변경
    fill_in "user[nickname]", with: "새로운닉네임"
    click_on "저장"

    # 성공 메시지 확인
    assert_text "프로필이 업데이트되었습니다" # 실제 메시지는 i18n에서 가져옴

    # 변경된 닉네임 확인
    @user.reload
    assert_equal "새로운닉네임", @user.nickname
  end

  test "알림 설정 페이지로 이동" do
    visit settings_profile_path

    # 알림 설정 링크 클릭
    within ".card-solid", match: :first do
      click_on "알림 설정"
    end

    # 알림 설정 페이지로 이동 확인
    assert_current_path settings_notifications_path
  end

  # 7.2 알림 설정 페이지 테스트
  test "알림 설정 페이지 접근" do
    visit settings_notifications_path

    # 페이지 제목 확인
    assert_selector "h1", text: "알림 설정"
  end

  test "뒤로 가기 버튼 표시" do
    visit settings_notifications_path

    # 뒤로 가기 버튼 확인
    assert_selector "button[onclick='history.back()']"
  end

  test "알림 설정 목록 표시" do
    visit settings_notifications_path

    # 알림 설정 카드
    assert_selector ".card-solid"

    within ".card-solid" do
      # 새 사진 알림
      assert_text "새 사진 알림"
      assert_text "가족이 새 사진을 올리면 알려드려요"
      assert_selector "button[data-controller='toggle']", count: 4

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
  end

  test "토글 스위치 ON/OFF 상태 구분" do
    visit settings_notifications_path

    within ".card-solid" do
      toggles = all("button[data-controller='toggle']")

      # ON 상태 토글 (bg-primary-500)
      on_toggles = toggles.select { |t| t[:class].include?("bg-primary-500") }
      assert on_toggles.count >= 1, "ON 상태 토글이 최소 1개 있어야 합니다"

      # OFF 상태 토글 (bg-warm-gray-200)
      off_toggles = toggles.select { |t| t[:class].include?("bg-warm-gray-200") }
      assert off_toggles.count >= 1, "OFF 상태 토글이 최소 1개 있어야 합니다"
    end
  end

  test "디자인 시스템 준수 - card-solid 클래스" do
    visit settings_profile_path

    # card-solid 클래스 사용 확인
    assert_selector ".card-solid", minimum: 3
  end

  test "디자인 시스템 준수 - lucide 사용" do
    visit settings_profile_path

    # SVG 아이콘 확인 (lucide)
    assert_selector "svg", minimum: 8
  end

  test "디자인 시스템 준수 - 간격 시스템" do
    visit settings_profile_path

    # px-4 py-6 space-y-6 클래스 확인
    assert_selector ".px-4.py-6.space-y-6"
  end

  test "접근성 - 터치 타겟 크기" do
    visit settings_profile_path

    # 모든 버튼과 링크가 충분한 크기를 가져야 함
    # 최소 py-4 (48px 높이 보장)
    within ".card-solid", match: :first do
      links = all("a")
      links.each do |link|
        assert link[:class].include?("py-4"), "링크가 충분한 터치 영역을 가져야 합니다"
      end
    end
  end
end
