# frozen_string_literal: true

module Photos
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
        # 알림 생성
        NotificationService.notify_reaction_created(@reaction)

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
