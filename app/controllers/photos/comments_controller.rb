# frozen_string_literal: true

module Photos
  class CommentsController < ApplicationController
    include ActionView::RecordIdentifier
    include FamilyAccessible

    before_action :authenticate_user!
    before_action :require_onboarding!
    before_action :set_family
    before_action :set_photo
    before_action :set_comment, only: [ :destroy ]

    def index
      @comments = @photo.comments.includes(:user).order(created_at: :asc)

      respond_to do |format|
        format.json { render json: { data: @comments.as_json(include: :user) } }
        format.html { redirect_to family_photo_path(@family, @photo) }
      end
    end

    def create
      @comment = @photo.comments.build(comment_params)
      @comment.user = current_user

      if @comment.save
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.append(dom_id(@photo, :comments), partial: "photos/comments/comment", locals: { comment: @comment }) }
          format.json { render json: @comment.as_json(only: [ :id, :body, :created_at ]) }
          format.html { redirect_to family_photo_path(@family, @photo) }
        end
      else
        respond_to do |format|
          format.json { render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity }
          format.html { redirect_to family_photo_path(@family, @photo), alert: @comment.errors.full_messages.join(", ") }
        end
      end
    end

    def destroy
      if @comment.user == current_user
        @comment.destroy
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@comment)) }
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

    def set_comment
      @comment = @photo.comments.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:body)
    end
  end
end
