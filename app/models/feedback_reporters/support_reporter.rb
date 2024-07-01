class SupportReporter < FeedbackReporter
  attr_accessor :user_agent, :referer, :rollout, :site_revision, :site_skin

  def report_attributes
    super.deep_merge(
      "departmentId" => department_id,
      "subject" => subject,
      "description" => ticket_description,
      "cf" => custom_zoho_fields
    )
  end

  private

  def custom_zoho_fields
    {
      "cf_archive_version" => site_revision.presence || "Unknown site revision",
      "cf_rollout" => rollout.presence || "Unknown",
      "cf_user_agent" => user_agent.presence || "Unknown user agent",
      "cf_ip" => ip_address.presence || "Unknown",
      "cf_referer" => referer.presence || "",
      "cf_site_skin" => site_skin&.public ? site_skin.title : "Custom skin"
    }
  end

  def department_id
    ArchiveConfig.SUPPORT_ZOHO_DEPARTMENT_ID
  end

  def subject
    return "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{title.html_safe}" if title.present?

    "[#{ArchiveConfig.APP_SHORT_NAME}] Support - No Title"
  end

  def ticket_description
    return "No description submitted." if description.blank?

    strip_images(description.html_safe, keep_src: true)
  end
end
