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
    return unless current_user

    Rails.cache.fetch("muted/#{current_user.id}/mute_css") do
      return if current_user.muted_users.empty?

      muted_users_css_classes = current_user.muted_users.map { |muted_user| ".user-#{muted_user.id}" }
      
      "<style>#{muted_users_css_classes.join(', ')} {display: none !important; visibility: hidden !important;}</style>".html_safe
    end
  end

  def user_has_muted_users?
    !current_user.muted_users.empty? if current_user
  end
end
