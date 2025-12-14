# frozen_string_literal: true

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Kakao < OmniAuth::Strategies::OAuth2
      option :name, "kakao"

      option :client_options, {
        site: "https://kauth.kakao.com",
        authorize_url: "/oauth/authorize",
        token_url: "/oauth/token"
      }

      option :authorize_params, {
        scope: "profile_nickname profile_image account_email"
      }

      uid { raw_info["id"].to_s }

      info do
        {
          name: kakao_account.dig("profile", "nickname"),
          email: kakao_account["email"],
          nickname: kakao_account.dig("profile", "nickname"),
          image: kakao_account.dig("profile", "profile_image_url")
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get(
          "https://kapi.kakao.com/v2/user/me",
          headers: { "Authorization" => "Bearer #{access_token.token}" }
        ).parsed
      end

      private

      def kakao_account
        raw_info["kakao_account"] || {}
      end

      def callback_url
        full_host + callback_path
      end
    end
  end
end
