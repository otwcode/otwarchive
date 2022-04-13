module Justifiable
  extend ActiveSupport::Concern

  included do
    attr_accessor :ticket_number
    attr_reader :ticket_url

    validates :ticket_number,
              presence: true,
              numericality: { only_integer: true },
              if: -> { enabled? }

    validate :ticket_number_exists_in_tracker, if: -> { enabled? }
  end

  private

  def enabled?
    # Only require a ticket if the record has been changed by an admin.
    User.current_user.is_a?(Admin) && changed?
  end

  def ticket_number_exists_in_tracker
    # Skip ticket lookup if the previous validations fail.
    return if errors.present?

    # The ticket must be open and the admin must have the role matching the ticket's department.
    if ticket.present? && ticket["status"].present? && ticket["status"] != "Closed" &&
       (admin_can_use_policy_and_abuse_ticket? || admin_can_use_support_ticket?)
      @ticket_url = ticket["webUrl"]
      return
    end

    errors.add(:ticket_number, :required)
  end

  def admin_can_use_policy_and_abuse_ticket?
    (User.current_user.roles & %w[policy_and_abuse superadmin]).present? && ticket["departmentId"] == ArchiveConfig.ABUSE_ZOHO_DEPARTMENT_ID
  end

  def admin_can_use_support_ticket?
    (User.current_user.roles & %w[superadmin support]).present? && ticket["departmentId"] == ArchiveConfig.SUPPORT_ZOHO_DEPARTMENT_ID
  end

  def ticket
    @ticket ||= zoho_resource_client.find_ticket(ticket_number)
  end

  def zoho_resource_client
    @zoho_resource_client ||= ZohoResourceClient.new(access_token: ZohoAuthClient.new.access_token)
  end
end
