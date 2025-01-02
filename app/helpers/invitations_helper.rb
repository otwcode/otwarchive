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
    return link_to(invitation.invitee.login, invitation.invitee) if invitation.invitee.present?
    return t("invitations.invitation.deleted_user_with_id", user_id: invitation.invitee_id) if User.current_user.is_a?(Admin)

    t("invitations.invitation.deleted_user")
  end
end
