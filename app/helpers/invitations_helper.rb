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

    if User.current_user.is_a?(Admin) && policy(invitation).access_invitee_details?
      return t("invitations.invitation.user_id_deleted", user_id: invitation.invitee_id) if invitation.invitee.blank?

      return link_to(invitation.invitee.login, admin_user_path(invitation.invitee))
    end

    return t("invitations.invitation.deleted_user") if invitation.invitee.blank?

    link_to(invitation.invitee.login, invitation.invitee) if invitation.invitee.present?
  end
end
