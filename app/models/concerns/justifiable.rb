module Justifiable
  extend ActiveSupport::Concern

  included do
    attr_accessor :ticket_number
    attr_reader :ticket_url

    before_validation :strip_octothorpe
    validates :ticket_number,
              presence: true,
              # i18n-tasks-use t("activerecord.errors.messages.numeric_with_optional_hash")
              numericality: { only_integer: true,
                              message: :numeric_with_optional_hash },
              if: :enabled?

    validate :ticket_number_exists_in_tracker, if: :enabled?
  end

  private

  def strip_octothorpe
    return if ticket_number.is_a?(Integer)

    self.ticket_number = self.ticket_number.delete_prefix("#") unless self.ticket_number.nil?
  end

  def enabled?
    # Only require a ticket if the record has been changed by an admin.
    User.current_user.is_a?(Admin) && changed?
  end

  def ticket_number_exists_in_tracker
    # Skip ticket lookup if the previous validations fail.
    return if errors.present?

    if ticket.blank?
      errors.add(:ticket_number, :required)
      return
    end

    # The ticket must not be closed.
    if ticket["status"].blank? || ticket["status"] == "Closed"
      errors.add(:ticket_number, :closed_ticket)
      return
    end

    # The admin must have the role matching the ticket's department.
    if admin_can_use_abuse_ticket? || admin_can_use_support_ticket?
      @ticket_url = ticket["webUrl"]
    else
      errors.add(:ticket_number, :invalid_department)
    end
  end

  def admin_can_use_abuse_ticket?
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
