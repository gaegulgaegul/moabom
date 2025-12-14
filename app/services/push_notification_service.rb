# frozen_string_literal: true

# PushNotificationService - 푸시 알림 전송 서비스
#
# MVP: 스텁 구현 (로그만 출력)
# TODO: P1에서 FCM/APNs SDK 연동
class PushNotificationService
  Result = Data.define(:success?, :error)

  def self.call(device:, title:, body:, data: {})
    new(device: device, title: title, body: body, data: data).call
  end

  def initialize(device:, title:, body:, data: {})
    @device = device
    @title = title
    @body = body
    @data = data
  end

  def call
    return Result.new(success?: false, error: "push_token이 없습니다.") unless device.push_token.present?

    case device.platform
    when "ios"
      send_to_apns
    when "android"
      send_to_fcm
    else
      Result.new(success?: false, error: "지원하지 않는 플랫폼입니다.")
    end
  rescue StandardError => e
    Rails.logger.error("Push notification failed: #{e.message}")
    Result.new(success?: false, error: e.message)
  end

  private

  attr_reader :device, :title, :body, :data

  def send_to_apns
    # TODO: APNs SDK 연동 (P1)
    Rails.logger.info("📱 [APNs Stub] Sending to #{device.push_token}: #{title} - #{body}")
    Result.new(success?: true, error: nil)
  end

  def send_to_fcm
    # TODO: FCM SDK 연동 (P1)
    Rails.logger.info("📱 [FCM Stub] Sending to #{device.push_token}: #{title} - #{body}")
    Result.new(success?: true, error: nil)
  end
end
