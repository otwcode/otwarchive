module InvitationsHelper
  def creator_link(invitation)
    case invitation.creator
    when User
      link_to(invitation.creator.login, invitation.creator)
    when Admin
      invitation.creator.login
    else
      t("invitations.invitation.queue")
    end
  end

  def invitee_link(invitation)
    return unless invitation.invitee_type == "User"
    return t("invitations.invitation.deleted_user", user_id: invitation.invitee_id) if invitation.invitee.blank?

    link_to(invitation.invitee.login, invitation.invitee)
  end
end
