# frozen_string_literal: true

require "test_helper"

class TailwindcssTest < ActiveSupport::TestCase
  test "tailwindcss build succeeds" do
    # TailwindCSS 빌드가 성공하는지 확인
    result = system("rails tailwindcss:build", out: File::NULL, err: File::NULL)
    assert result, "TailwindCSS build failed"
  end

  test "tab-item classes are defined" do
    css_path = Rails.root.join("app/assets/builds/tailwind.css")

    # 빌드 실행
    system("rails tailwindcss:build", out: File::NULL, err: File::NULL)

    assert File.exist?(css_path), "TailwindCSS build output not found"

    css_content = File.read(css_path)

    # tab-item 클래스가 정의되어 있는지 확인
    assert_match(/\.tab-item/, css_content, "tab-item class not found in CSS")
  end

  test "tab-item-active classes are defined" do
    css_path = Rails.root.join("app/assets/builds/tailwind.css")

    # 빌드 실행
    system("rails tailwindcss:build", out: File::NULL, err: File::NULL)

    assert File.exist?(css_path), "TailwindCSS build output not found"

    css_content = File.read(css_path)

    # tab-item-active 클래스가 정의되어 있는지 확인
    assert_match(/\.tab-item-active/, css_content, "tab-item-active class not found in CSS")
  end

  test "bg-gradient-warm is defined" do
    css_path = Rails.root.join("app/assets/builds/tailwind.css")

    # 빌드 실행
    system("rails tailwindcss:build", out: File::NULL, err: File::NULL)

    assert File.exist?(css_path), "TailwindCSS build output not found"

    css_content = File.read(css_path)

    # bg-gradient-warm 클래스가 정의되어 있는지 확인
    assert_match(/\.bg-gradient-warm/, css_content, "bg-gradient-warm class not found in CSS")
  end
end
