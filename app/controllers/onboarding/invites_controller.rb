# frozen_string_literal: true

module Onboarding
  class InvitesController < ApplicationController
    before_action :authenticate_user!

    def show
      @family = current_user.families.first
      @invitation = @family.invitations.create!(
        inviter: current_user,
        role: :member
      )
      @invite_url = accept_invitation_url(@invitation.token)
    end
  end
end
