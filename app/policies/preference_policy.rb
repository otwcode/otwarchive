class PreferencePolicy < ApplicationPolicy
  READ_ACCESS_ROLES = %w[superadmin policy_and_abuse support].freeze
  EDIT_ROLES = %w[superadmin support].freeze

  def read_access?
    user_has_roles?(READ_ACCESS_ROLES)
  end

  def edit_access?
    user_has_roles?(EDIT_ROLES)
  end

  # Define which roles can update which attributes
  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "superadmin" => %i[skin_id],
    "support" => %i[skin_id]
  }.freeze

  def permitted_attributes
    if user.is_a?(Admin)
      ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
    else
      [:minimize_search_engines,
       :disable_share_links,
       :adult,
       :view_full_works,
       :hide_warnings,
       :hide_freeform,
       :disable_work_skins,
       :skin_id,
       :time_zone,
       :preferred_locale,
       :work_title_format,
       :comment_emails_off,
       :comment_inbox_off,
       :comment_copy_to_self_off,
       :kudos_emails_off,
       :admin_emails_off,
       :allow_collection_invitation,
       :collection_emails_off,
       :collection_inbox_off,
       :recipient_emails_off,
       :history_enabled,
       :first_login,
       :banner_seen,
       :allow_cocreator,
       :allow_gifts,
       :guest_replies_off]
    end
  end

  alias index? read_access?
  alias update? edit_access?
end
