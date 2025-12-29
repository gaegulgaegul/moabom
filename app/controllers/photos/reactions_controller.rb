# frozen_string_literal: true

module Photos
  # Photos::ReactionsController
  #
  # 역할: 사진에 대한 이모지 반응 추가/삭제
  #
  # 주요 기능:
  # - 반응 추가 (create) - 기존 반응 있으면 이모지 변경, Turbo Stream 지원
  # - 반응 삭제 (destroy) - 본인 반응만 삭제 가능
  # - 반응 생성 시 NotificationService로 알림 발송
  # - HTML/JSON/Turbo Stream 멀티포맷 응답
  #
  # 연관 클래스: Reaction, Photo, NotificationService, FamilyAccessible concern
  class ReactionsController < ApplicationController
    include ActionView::RecordIdentifier
    include FamilyAccessible

    before_action :authenticate_user!
    before_action :require_onboarding!
    before_action :set_family
    before_action :set_photo
    before_action :set_reaction, only: [ :destroy ]

    def create
      @reaction = @photo.reactions.find_or_initialize_by(user: current_user)
      @reaction.emoji = reaction_params[:emoji]

      if @reaction.save
        # 알림 생성 (실패해도 반응 생성은 성공으로 처리)
        begin
          NotificationService.notify_reaction_created(@reaction)
        rescue StandardError => e
          Rails.logger.error "Failed to create notification for reaction: " \
                             "reaction_id=#{@reaction.id}, user_id=#{current_user.id}, " \
                             "photo_id=#{@photo.id}, error=#{e.class}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          # TODO: Report to error tracker (Sentry/Errbit) when available
          # Sentry.capture_exception(e, extra: { reaction_id: @reaction.id, user_id: current_user.id })
        end

        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@photo, :reactions), partial: "photos/reactions/reactions", locals: { photo: @photo }) }
          format.json { render json: @reaction.as_json(only: [ :id, :emoji ]) }
          format.html { redirect_to family_photo_path(@family, @photo) }
        end
      else
        respond_to do |format|
          format.json { render json: { errors: @reaction.errors.full_messages }, status: :unprocessable_entity }
          format.html { redirect_to family_photo_path(@family, @photo), alert: @reaction.errors.full_messages.join(", ") }
        end
      end
    end

    def destroy
      if @reaction.user == current_user
        @reaction.destroy
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@photo, :reactions), partial: "photos/reactions/reactions", locals: { photo: @photo }) }
          format.json { head :no_content }
          format.html { redirect_to family_photo_path(@family, @photo) }
        end
      else
        respond_to do |format|
          format.json { render json: { error: "권한이 없습니다." }, status: :forbidden }
          format.html { redirect_to family_photo_path(@family, @photo), alert: "권한이 없습니다.", status: :forbidden }
        end
      end
    end

    private

    def set_photo
      @photo = @family.photos.find(params[:photo_id])
    end

    def set_reaction
      @reaction = @photo.reactions.find(params[:id])
    end

    def reaction_params
      params.require(:reaction).permit(:emoji)
    end
  end
end
