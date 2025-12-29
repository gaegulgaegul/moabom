# frozen_string_literal: true

# ApplicationRecord
#
# 역할: 모든 ActiveRecord 모델의 기본 클래스
#
# 주요 기능:
# - 프로젝트 내 모든 모델의 공통 동작 정의
# - Rails의 primary database 연결 관리
# - 공통 메서드 및 concerns의 기본 위치
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
