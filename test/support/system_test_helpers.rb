# frozen_string_literal: true

module SystemTestHelpers
  # 시스템 테스트에서 사용자 로그인 헬퍼
  def sign_in(user)
    # OmniAuth 콜백 시뮬레이션
    # 실제 OAuth 플로우 없이 세션 생성
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:kakao] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: {
        name: user.nickname,
        email: user.email
      }
    )

    visit "/auth/kakao"
    visit "/auth/kakao/callback"
  end

  # 로그아웃 헬퍼
  def sign_out
    click_on "로그아웃" if has_button?("로그아웃")
  end
end
