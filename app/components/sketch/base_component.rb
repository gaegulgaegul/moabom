# frozen_string_literal: true

module Sketch
  # Sketch 스타일 ViewComponent 기본 클래스
  #
  # 역할: Frame0 스케치 UI 요소를 위한 공통 기능 제공
  #
  # 주요 기능:
  # - 거칠기(roughness) 수준 관리 (smooth, normal, rough, sketchy)
  # - 컴포넌트 크기 관리 (xs, sm, md, lg, xl)
  # - 비활성화/로딩 상태 처리
  # - Stimulus 컨트롤러 데이터 생성
  #
  # @param roughness [Symbol] 스케치 거칠기 수준
  # @param size [Symbol] 컴포넌트 크기
  # @param disabled [Boolean] 비활성화 상태
  # @param loading [Boolean] 로딩 상태
  class BaseComponent < ViewComponent::Base
    ROUGHNESS_LEVELS = {
      smooth: 0.5,
      normal: 1.5,
      rough: 2.5,
      sketchy: 3.5
    }.freeze

    SIZES = {
      xs: { padding: "py-1 px-2", text: "text-xs", icon: "w-3 h-3" },
      sm: { padding: "py-2 px-3", text: "text-sm", icon: "w-4 h-4" },
      md: { padding: "py-3 px-4", text: "text-base", icon: "w-5 h-5" },
      lg: { padding: "py-4 px-6", text: "text-lg", icon: "w-6 h-6" },
      xl: { padding: "py-5 px-8", text: "text-xl", icon: "w-7 h-7" }
    }.freeze

    def initialize(roughness: :normal, size: :md, disabled: false, loading: false, **options)
      @roughness = roughness
      @size = size
      @disabled = disabled
      @loading = loading
      @options = options
      super()
    end

    private

    attr_reader :roughness, :size, :disabled, :loading, :options

    def roughness_value
      ROUGHNESS_LEVELS.fetch(roughness, ROUGHNESS_LEVELS[:normal])
    end

    def size_config
      SIZES.fetch(size, SIZES[:md])
    end

    def random_dasharray
      patterns = [
        "4, 3",
        "5, 2",
        "3, 4",
        "6, 2, 2, 2",
        "8, 3",
        "4, 2, 1, 2"
      ]
      patterns.sample
    end

    def random_seed
      rand(1000)
    end

    def disabled?
      disabled
    end

    def loading?
      loading
    end

    def base_classes
      [
        "sketch-component",
        "relative",
        "transition-all duration-200",
        disabled? ? "opacity-50 cursor-not-allowed" : "",
        loading? ? "cursor-wait" : ""
      ].compact.join(" ")
    end

    def stimulus_data(controller_name, extra_values = {})
      base = {
        controller: "sketch-#{controller_name}",
        "sketch-#{controller_name}-roughness-value": roughness_value,
        "sketch-#{controller_name}-seed-value": random_seed
      }
      base.merge(extra_values)
    end
  end
end
