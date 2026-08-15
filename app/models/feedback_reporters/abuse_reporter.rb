class AbuseReporter < FeedbackReporter
  attr_accessor :creator_ids, :user_agent

  def report_attributes
    super.deep_merge(
      "departmentId" => department_id,
      "subject" => subject,
      "description" => ticket_description,
      "cf" => custom_zoho_fields,
      "channel" => channel
    )
  end

  private

  def custom_zoho_fields
    # To avoid issues where Zoho ticket creation silently fails, only grab the first
    # 2080 characters of the referer URL. That may miss some complex search queries,
    # but still keep enough to be useful most of the time.
    truncated_referer = url.present? ? url[0..2079] : ""
    {
      "cf_ip" => ip_address.presence || "Unknown IP",
      "cf_ticket_url" => truncated_referer,
      "cf_user_id" => creator_ids.presence || "",
      "cf_user_agent" => user_agent || "Unknown user agent"
    }
  end

  def department_id
    ArchiveConfig.ABUSE_ZOHO_DEPARTMENT_ID
  end

  def subject
    return "[#{ArchiveConfig.APP_SHORT_NAME}] Abuse - #{title.html_safe}" if title.present?

    "[#{ArchiveConfig.APP_SHORT_NAME}] Abuse - No Subject"
  end

  def ticket_description
    return "No comment submitted." if description.blank?

    strip_images(description.html_safe, keep_src: true)
  end

  def channel
    "Abuse Form"
  end
end
