module InvitationsHelper

  def invitee_link(invitation)
    if invitation.invitee
      link_to(invitation.invitee.login, invitation.invitee)
    end
  end
end
