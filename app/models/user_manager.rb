# Allows admins to manage user status and next of kin
# via the admin users interface
class UserManager
  attr_reader :admin,
              :user,
              :kin_name,
              :kin_email,
              :admin_note,
              :admin_action,
              :suspension_length,
              :errors,
              :successes

  PERMITTED_ACTIONS = %w[note warn suspend unsuspend ban unban spamban].freeze
  REQUIRED_ADMIN_ROLES = %w(superadmin policy_and_abuse).freeze

  def initialize(admin, params)
    @admin = admin
    @user  = User.find_by(login: params[:user_login])
    @kin_name           = params[:next_of_kin_name]
    @kin_email          = params[:next_of_kin_email]
    @admin_note         = params[:admin_note]
    @admin_action       = params[:admin_action]
    @suspension_length  = params[:suspend_days]
    @errors = []
    @successes = []
  end

  def save
    check_correct_admin_roles &&
      validate_user_and_admin &&
      validate_admin_note &&
      validate_suspension &&
      validate_next_of_kin &&
      save_next_of_kin &&
      save_admin_action
  end

  def success_message
    successes.join(" ")
  end

  def error_message
    errors.join(" ")
  end

  private

  def check_correct_admin_roles
    admin_access = (admin.roles & REQUIRED_ADMIN_ROLES).any?

    if admin_access
      true
    else
      errors << "Must have a valid admin role to proceed."
      false
    end
  end

  def validate_user_and_admin
    if user && admin
      true
    else
      errors << "Must have a valid user and admin account to proceed."
      false
    end
  end

  def validate_admin_note
    return true if admin_note.present? || admin_action.blank?

    if admin_action == "spamban"
      @admin_note = "Banned for spam"
    elsif admin_action.present?
      errors << "You must include notes in order to perform this action."
      false
    end
  end

  def validate_suspension
    if admin_action == "suspend" && suspension_length.blank?
      errors << "Please enter the number of days for which the user should be suspended."
      false
    else
      true
    end
  end

  # Basically, we either want valid data for both name and email
  # or we want them both to be blank, which means do nothing
  # or delete anything that already exists
  def validate_next_of_kin
    error = nil
    if kin_name.present?
      if kin_email.blank?
        error = "Fannish next of kin email is missing."
      elsif !User.where(login: kin_name).exists?
        error = "Fannish next of kin user is invalid."
      end
    elsif kin_email.present?
      error = "Fannish next of kin user is missing."
    end
    if error
      errors << error
      false
    else
      true
    end
  end

  def save_next_of_kin
    return true if user.fannish_next_of_kin.nil? && kin_name.blank? && kin_email.blank?

    same_kin_user = User.find_by(login: kin_name)&.id == user.fannish_next_of_kin&.kin_id
    same_kin_email = user.fannish_next_of_kin&.kin_email == kin_email
    return true if same_kin_user && same_kin_email

    if FannishNextOfKin.update_for_user(user, kin_name, kin_email)
      successes << "Fannish next of kin was updated."
    else
      errors << "Fannish next of kin failed to update."
      false
    end
  end

  def save_admin_action
    return true if admin_action.blank?

    if admin_action == 'spamban'
      ban_user
    elsif PERMITTED_ACTIONS.include?(admin_action)
      send("#{admin_action}_user")
    end
  end

  def note_user
    log_action(ArchiveConfig.ACTION_NOTE)
    successes << "Note was recorded."
  end

  def warn_user
    log_action(ArchiveConfig.ACTION_WARN)
    successes << "Warning was recorded."
  end

  def suspend_user
    user.suspended = true
    user.suspended_until = suspension_length.to_i.days.from_now
    user.save!
    log_action(ArchiveConfig.ACTION_SUSPEND, enddate: user.suspended_until)
    successes << "User has been temporarily suspended."
  end

  def unsuspend_user
    user.suspended = false
    user.suspended_until = nil
    user.save!
    log_action(ArchiveConfig.ACTION_UNSUSPEND)
    successes << "Suspension has been lifted."
  end

  def ban_user
    user.banned = true
    user.save!
    log_action(ArchiveConfig.ACTION_BAN)
    successes << "User has been permanently suspended."
  end

  def unban_user
    user.banned = false
    user.save!
    log_action(ArchiveConfig.ACTION_UNSUSPEND)
    successes << "Suspension has been lifted."
  end

  def log_action(message, options = {})
    options.merge!(
      action: message, 
      note: admin_note, 
      admin_id: admin.id
    )
    user.create_log_item(options)
  end
end
