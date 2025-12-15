# frozen_string_literal: true

module Families
  class PhotosController < ApplicationController
    include FamilyAccessible

    MAX_BATCH_SIZE = 100

    before_action :authenticate_user!
    before_action :require_onboarding!
    before_action :set_family
    before_action :set_photo, only: [ :show, :edit, :update, :destroy ]
    before_action :validate_batch_params, only: [ :batch ]
    before_action :authorize_upload, only: [ :create, :batch ]
    before_action :authorize_delete, only: [ :destroy ]

    def index
      @photos = @family.photos.includes(:uploader, :child).with_eager_loaded_image.recent

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

    def authorize_upload
      membership = current_user.membership_for(@family)
      unless membership&.can_upload?
        redirect_to root_path, alert: "권한이 없습니다."
      end
    end

    def authorize_delete
      membership = current_user.membership_for(@family)
      unless membership&.can_delete_photo?(@photo)
        redirect_to root_path, alert: "권한이 없습니다."
      end
    end

    def validate_batch_params
      photos_param = params[:photos]

      # photos 파라미터 존재 여부 확인
      if photos_param.nil?
        return render json: {
          error: {
            code: "bad_request",
            message: "photos 파라미터가 없습니다."
          }
        }, status: :bad_request
      end

      # 배열 타입 검증
      unless photos_param.is_a?(Array)
        return render json: {
          error: {
            code: "bad_request",
            message: "photos는 배열 형식이어야 합니다."
          }
        }, status: :bad_request
      end

      # 빈 배열 체크 (빈 배열이거나 빈 문자열만 포함한 경우)
      if photos_param.empty? || photos_param.all? { |p| p.blank? }
        return render json: {
          error: {
            code: "bad_request",
            message: "업로드할 사진이 비어있습니다."
          }
        }, status: :bad_request
      end

      # 최대 개수 초과 체크
      return if photos_param.size <= MAX_BATCH_SIZE

      render json: {
        error: {
          code: "bad_request",
          message: "최대 #{MAX_BATCH_SIZE}개까지 업로드 가능합니다. (현재: #{photos_param.size}개)"
        }
      }, status: :bad_request
    end
  end
end
