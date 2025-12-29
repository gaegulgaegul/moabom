# frozen_string_literal: true

# Comment
#
# 역할: 사진에 대한 댓글을 관리하는 모델
#
# 주요 기능:
# - 사진에 댓글 작성/삭제
# - 댓글 본문 길이 제한 (최대 1000자)
# - 댓글 생성 시 알림 발송 연동
#
# 연관 클래스: Photo, User, Notification
class Comment < ApplicationRecord
  MAX_BODY_LENGTH = 1000

  belongs_to :photo
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true
  validates :body, length: { maximum: MAX_BODY_LENGTH }
end
