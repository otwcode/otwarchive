module InvitationsHelper

  def creator_link(invitation)
    if invitation.creator.is_a?(User)
      link_to(invitation.creator.login, invitation.creator)
    elsif invitation.creator.is_a?(Admin)
      invitation.creator.login
    else
      "queue"
    end
  end

  def invitee_link(invitation)
    if invitation.invitee && invitation.invitee.is_a?(User)
      link_to(invitation.invitee.login, invitation.invitee)
    end
  end

  def new_account_link
    return ts('Account creation disabled') unless @admin_settings.account_creation_enabled?  
    if @admin_settings.creation_requires_invite?
      link_to ts('Get an Invite'), invite_requests_path
    else
      link_to ts('Create an Account'), new_user_path
    end 
  end
end
