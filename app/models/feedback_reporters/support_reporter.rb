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
    # To avoid issues where Zoho ticket creation silently fails, only grab the first
    # 255 characters of the referer URL. That may miss some complex search queries,
    # but still keep enough to be useful most of the time.
    truncated_referer = referer.present? ? referer[0..254] : "Unknown URL"
    {
      "cf_archive_version" => site_revision.presence || "Unknown site revision",
      "cf_rollout" => rollout.presence || "Unknown",
      "cf_user_agent" => user_agent.presence || "Unknown user agent",
      "cf_ip" => ip_address.presence || "Unknown IP",
      "cf_url" => truncated_referer,
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
