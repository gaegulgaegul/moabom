# frozen_string_literal: true

module Families
  class PhotosController < ApplicationController
    include FamilyAccessible

    before_action :authenticate_user!
    before_action :require_onboarding!
    before_action :set_family
    before_action :set_photo, only: [ :show, :edit, :update, :destroy ]

    def index
      @photos = @family.photos.includes(:uploader, :child).recent

      # 아이별 필터링
      @photos = @photos.where(child_id: params[:child_id]) if params[:child_id].present?

      # 월별 필터링
      if params[:year].present? && params[:month].present?
        @photos = @photos.by_month(params[:year].to_i, params[:month].to_i)
      end

      # 페이지네이션 (간단한 offset 방식)
      page = (params[:page] || 1).to_i
      per_page = 20
      @photos = @photos.offset((page - 1) * per_page).limit(per_page)

      respond_to do |format|
        format.html
        format.json { render json: { data: @photos.as_json(include: [ :uploader, :child ]) } }
      end
    end

    def show
    end

    def new
      @photo = @family.photos.build
    end

    def create
      @photo = @family.photos.build(photo_params)
      @photo.uploader = current_user

      if @photo.save
        redirect_to family_photo_path(@family, @photo), notice: "사진이 업로드되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def batch
      results = []

      (params[:photos] || []).each do |photo_params|
        photo = @family.photos.build(
          caption: photo_params[:caption],
          taken_at: photo_params[:taken_at],
          child_id: photo_params[:child_id]
        )
        photo.uploader = current_user
        photo.image.attach(photo_params[:image]) if photo_params[:image]

        if photo.save
          results << { success: true, id: photo.id, caption: photo.caption }
        else
          results << { success: false, errors: photo.errors.full_messages }
        end
      end

      render json: { results: results }
    end

    def edit
    end

    def update
      if @photo.update(photo_params)
        redirect_to family_photo_path(@family, @photo), notice: "사진이 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @photo.destroy
      redirect_to family_photos_path(@family), notice: "사진이 삭제되었습니다."
    end

    private

    def set_photo
      @photo = @family.photos.find(params[:id])
    end

    def photo_params
      params.require(:photo).permit(:image, :caption, :taken_at, :child_id)
    end
  end
end
