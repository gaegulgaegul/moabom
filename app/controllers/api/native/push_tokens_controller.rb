# frozen_string_literal: true

module Api
  module Native
    class PushTokensController < Api::BaseController
      def create
        device = current_user.devices.find_or_initialize_by(device_id: device_params[:device_id])
        device.assign_attributes(device_params)

        if device.save
          render json: {
            status: "success",
            device: {
              id: device.id,
              user_id: device.user_id,
              device_id: device.device_id,
              platform: device.platform,
              push_token: device.push_token
            }
          }, status: :created
        else
          render json: {
            error: {
              code: "validation_failed",
              message: device.errors.full_messages.join(", ")
            }
          }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        render json: {
          error: {
            code: "bad_request",
            message: e.message
          }
        }, status: :bad_request
      end

      def destroy
        device = current_user.devices.find_by(device_id: params[:id])

        if device
          device.destroy
          render json: { status: "success" }
        else
          render json: {
            error: {
              code: "not_found",
              message: "Device not found"
            }
          }, status: :not_found
        end
      end

      private

      def device_params
        params.require(:platform)
        params.require(:device_id)

        params.permit(:platform, :device_id, :push_token, :app_version, :os_version)
      end
    end
  end
end
