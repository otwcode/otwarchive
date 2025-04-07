class RolesUser < ApplicationRecord
  belongs_to :user
  belongs_to :role

  delegate :enqueue_to_index, to: :user

  after_create :log_role_addition
  after_create :enqueue_to_index
  after_destroy :log_role_removal
  after_destroy :destroy_last_wrangling_activity
  after_destroy :enqueue_to_index

  def log_role_addition
    admin = User.current_user
    note = "Change made by #{admin&.login}"
    user.create_log_item({ admin_id: admin&.id,
                           action: ArchiveConfig.ACTION_ADD_ROLE,
                           note: note,
                           role_id: role_id })
  end

  def log_role_removal
    admin = User.current_user
    note = "Change made by #{admin&.login}"
    user.create_log_item({ admin_id: admin&.id,
                           action: ArchiveConfig.ACTION_REMOVE_ROLE,
                           note: note,
                           role_id: role_id })
  end

  # After removing the tag_wrangler role, remove the
  # user's last wrangling activity as well.
  def destroy_last_wrangling_activity
    return unless role.name == "tag_wrangler"

    user.last_wrangling_activity&.destroy
  end
end
