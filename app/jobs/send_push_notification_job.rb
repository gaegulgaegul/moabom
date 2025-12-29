# frozen_string_literal: true

# SendPushNotificationJob
#
# 역할: 푸시 알림 전송 백그라운드 작업
#
# 주요 기능:
# - Device ID로 디바이스 조회 후 푸시 알림 전송
# - PushNotificationService를 통해 APNs/FCM 전송
# - 디바이스 미존재 또는 전송 실패 시 로그 기록
#
# 연관 클래스: Device, PushNotificationService
class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(device_id, title, body, data = {})
    device = Device.find_by(id: device_id)

    unless device
      Rails.logger.warn("Device not found: #{device_id}")
      return
    end

    result = PushNotificationService.call(
      device: device,
      title: title,
      body: body,
      data: data
    )

    unless result.success?
      Rails.logger.error("Push notification failed for device #{device_id}: #{result.error}")
    end
  end
end
