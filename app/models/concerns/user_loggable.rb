module UserLoggable
  extend ActiveSupport::Concern

  included do
    before_destroy :log_removal_of_self_from_fnok_relationships
  end

  def log_removal_of_self_from_fnok_relationships
    fannish_next_of_kins.each do |fnok|
      fnok.user.log_removal_of_next_of_kin(self)
    end

    successor = fannish_next_of_kin&.kin
    log_removal_of_next_of_kin(successor)
  end

  def log_assignment_of_next_of_kin(kin, admin:)
    log_user_history(
      ArchiveConfig.ACTION_ADD_FNOK,
      options: { fnok_user_id: kin.id },
      admin: admin
    )

    kin.log_user_history(
      ArchiveConfig.ACTION_ADDED_AS_FNOK,
      options: { fnok_user_id: self.id },
      admin: admin
    )
  end

  def log_removal_of_next_of_kin(kin, admin: nil)
    return if kin.blank?

    log_user_history(
      ArchiveConfig.ACTION_REMOVE_FNOK,
      options: { fnok_user_id: kin.id },
      admin: admin
    )

    kin.log_user_history(
      ArchiveConfig.ACTION_REMOVED_AS_FNOK,
      options: { fnok_user_id: self.id },
      admin: admin
    )
  end

  def log_user_history(action, options: {}, admin: nil)
    if admin.present?
      options = {
        admin_id: admin.id,
        note: "Change made by #{admin.login}",
        **options
      }
    end

    create_log_item({
                      action: action,
                      **options
                    })
  end
end
