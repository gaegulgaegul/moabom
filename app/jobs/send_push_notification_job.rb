# frozen_string_literal: true

# SendPushNotificationJob - 푸시 알림 전송 백그라운드 작업
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
