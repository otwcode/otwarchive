module UserHistory
  def log_assignment_of_next_of_kin(user, kin, admin:)
    log_user_history(
      user,
      ArchiveConfig.ACTION_ADD_FNOK,
      options: { fnok_user_id: kin.id },
      admin: admin
    )

    log_user_history(
      kin,
      ArchiveConfig.ACTION_ADDED_AS_FNOK,
      options: { fnok_user_id: user.id },
      admin: admin
    )
  end

  def log_removal_of_next_of_kin(user, kin, admin: nil)
    return if kin.blank?

    log_user_history(
      user,
      ArchiveConfig.ACTION_REMOVE_FNOK,
      options: { fnok_user_id: kin.id },
      admin: admin
    )

    log_user_history(
      kin,
      ArchiveConfig.ACTION_REMOVED_AS_FNOK,
      options: { fnok_user_id: user.id },
      admin: admin
    )
  end

  def log_user_history(user, action, options: {}, admin: nil)
    return if user.nil?

    if admin.present?
      options = {
        admin_id: admin.id,
        note: "Change made by #{admin.login}",
        **options
      }
    end

    user.create_log_item({
                           action: action,                           
                           **options
                         })
  end
end
