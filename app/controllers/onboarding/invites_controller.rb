# frozen_string_literal: true

module Onboarding
  class InvitesController < ApplicationController
    before_action :authenticate_user!

    def show
      @family = current_user.families.first
      @invitation = find_or_create_invitation
      @invite_url = accept_invitation_url(@invitation.token)
    end

    private

    def find_or_create_invitation
      @family.invitations.active.first || @family.invitations.create!(
        inviter: current_user,
        role: :member
      )
    end
  end
end
