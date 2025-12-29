# frozen_string_literal: true

# FamilyAccessible
#
# 역할: 가족 리소스 접근 권한 확인 Concern
#
# 주요 기능:
# - current_user의 가족 멤버십 확인 후 @family 설정
# - 접근 권한 없을 시 root_path로 리다이렉트
#
# 사용 컨트롤러: Families::PhotosController 등 가족 중첩 리소스 컨트롤러
module FamilyAccessible
  extend ActiveSupport::Concern

  private

  def set_family
    @family = current_user.families.find_by(id: params[:family_id])
    redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
  end
end
