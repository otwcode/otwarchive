module MuteHelper
  def mute_link(user, mute: nil)
    if mute.nil?
      mute = user.mute_by_current_user
      muting_user = current_user
    else
      muting_user = mute.muter
    end

    if mute
      link_to(t("muted.unmute"), confirm_unmute_user_muted_user_path(muting_user, mute))
    else
      link_to(t("muted.mute"), confirm_mute_user_muted_users_path(muting_user, muted_id: user))
    end
  end

  def mute_css
    user = current_user
    
    return unless user

    muted_users_css_classes = user.muted_users.map { |muted_user| ".user-#{muted_user.id}" }

    return unless muted_users_css_classes

    "<style>#{muted_users_css_classes.join(', ')} {display: none !important; visibility: hidden !important;}</style>".html_safe
  end
end
  