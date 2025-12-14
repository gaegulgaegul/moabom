# frozen_string_literal: true

require "test_helper"

class ChildTest < ActiveSupport::TestCase
  setup do
    @family = families(:kim_family)
  end

  test "should be valid with all required attributes" do
    child = Child.new(
      family: @family,
      name: "아기",
      birthdate: Date.new(2023, 5, 15),
      gender: :male
    )
    assert child.valid?
  end

  test "should belong to family" do
    child = Child.new(name: "아기", birthdate: Date.current, gender: :female)
    assert_not child.valid?
    assert_includes child.errors[:family], "은(는) 필수입니다"
  end

  test "should require name" do
    child = Child.new(family: @family, birthdate: Date.current, gender: :male)
    assert_not child.valid?
    assert_includes child.errors[:name], "을(를) 입력해주세요"
  end

  test "should require birthdate" do
    child = Child.new(family: @family, name: "아기", gender: :male)
    assert_not child.valid?
    assert_includes child.errors[:birthdate], "을(를) 입력해주세요"
  end

  test "should have gender enum with correct values" do
    assert_equal({ "male" => 0, "female" => 1 }, Child.genders)
  end

  test "should calculate age in months" do
    child = Child.new(birthdate: 18.months.ago.to_date)
    assert_equal 18, child.age_in_months
  end

  test "should calculate age in years" do
    child = Child.new(birthdate: 2.years.ago.to_date)
    assert_equal 2, child.age_in_years
  end

  test "should format age as string" do
    child = Child.new(birthdate: 14.months.ago.to_date)
    assert_equal "1년 2개월", child.age_string
  end

  test "should format age for infant under 1 year" do
    child = Child.new(birthdate: 8.months.ago.to_date)
    assert_equal "8개월", child.age_string
  end
end
