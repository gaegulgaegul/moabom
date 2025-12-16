# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :set_invitation

  def show
    return handle_invalid_invitation if @invitation.nil?
    handle_expired_invitation if @invitation.expired?
  end

  def accept
    return handle_invalid_invitation if @invitation.nil?
    return handle_expired_invitation if @invitation.expired?
    return store_pending_invitation unless logged_in?
    return handle_already_member if already_member?

    join_family
    redirect_to dashboard_path, notice: "가족에 참여했습니다!"
  end

  private

  def set_invitation
    @invitation = Invitation.find_by(token: params[:token])
  end

  def handle_invalid_invitation
    redirect_to root_path, alert: "유효하지 않은 초대입니다."
  end

  def handle_expired_invitation
    redirect_to root_path, alert: "만료된 초대입니다."
  end

  def store_pending_invitation
    session[:pending_invitation_token] = @invitation.token
    redirect_to root_path, notice: "로그인 후 가족에 참여할 수 있습니다."
  end

  def handle_already_member
    redirect_to dashboard_path, alert: "이미 가족 구성원입니다."
  end

  def already_member?
    current_user.families.include?(@invitation.family)
  end

  def join_family
    FamilyMembership.create!(
      user: current_user,
      family: @invitation.family,
      role: @invitation.role
    )
    current_user.complete_onboarding!
  end
end
