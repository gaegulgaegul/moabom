# frozen_string_literal: true

module NavigationHelper
  # Wave 5: Phase 2 - 헤더 아이콘 버튼 헬퍼
  # 공통 헤더 아이콘 버튼 스타일과 구조를 제공
  #
  # @param icon [String] Heroicon 이름 (예: "bell", "cog-6-tooth")
  # @param path [String] 링크 경로
  # @param label [String] aria-label용 라벨
  # @param badge [Boolean] 뱃지 표시 여부 (기본: false)
  # @return [String] HTML 버튼 마크업
  def header_icon_button(icon:, path:, label:, badge: false)
    link_to path,
            class: "relative p-2 rounded-full hover:bg-cream-100
                    transition-colors duration-200 tap-highlight-none",
            "aria-label": label do
      concat heroicon(icon, variant: :outline,
                      options: { class: "w-6 h-6 text-warm-gray-700" })
      if badge
        concat content_tag(:span, "",
                          class: "absolute top-1 right-1 w-2 h-2 bg-accent-500 rounded-full",
                          "aria-label": t("notifications.unread_badge"))
      end
    end
  end
end
