module HomeHelper
  def html_to_text(string)
    string.gsub!(/<br\s*\/?>/, "\n")
    string.gsub!(/<\/?p>/, "\n\n")
    string = strip_tags(string)
    string.gsub!(/^[ \t]*/, "")
    while !string.gsub!(/\n\s*\n\s*\n/, "\n\n").nil?
      # keep going
    end
    return string
  end

  # A TOC section has an h4 header, p with intro link, and ol of subsections.
  def tos_table_of_contents_section(action)
    return unless %w[content privacy tos].include?(action)

    content = tos_section_header(action) + tos_section_intro_link(action) + tos_subsection_list(action)
    # If we're on /tos, /content, or /privacy, use the details tag to make
    # sections expandable and collapsable.
    if controller.controller_name == "home"
      # Use the open attribute to make the page's corresponding section expanded
      # by default.
      content_tag(:details, content, open: controller.action_name == action)
    else
      content
    end
  end

  private

  def tos_section_header(action)
    # If we're on /tos, /content, or /privacy, the corresponding section header
    # gets extra text indicating it is the current section.
    text = if controller.controller_name == "home" && controller.action_name == action
             t("home.tos_toc.#{action}.header_current")
           else
             t("home.tos_toc.#{action}.header")
           end
    heading = content_tag(:h4, text, class: "heading")
    # If we're on /tos, /content, or /privacy, use a summary tag around the h4
    # so it serves as the toggle to expand or collapse its section.
    if controller.controller_name == "home"
      content_tag(:summary, heading)
    else
      heading
    end
  end

  def tos_section_intro_link(action)
    content_tag(:p, link_to(t("home.tos_toc.#{action}.intro"), tos_anchor_url(action, action)))
  end

  def tos_subsection_list(action)
    items = case action
            when "content"
              content_policy_subsection_items
            when "privacy"
              privacy_policy_subsection_items
            when "tos"
              tos_subsection_items
            end
    content_tag(:ol, items.html_safe, style: "list-style-type: upper-alpha;")
  end

  # When we are on the /signup page, the entire TOS is displayed. This lets us
  # make sure that page only uses plain anchors in its TOC while the /tos,
  # /content, nad /privacy pages (found in the home controller) sometimes
  # point to other pages.
  def tos_anchor_url(action, anchor)
    if controller.controller_name == "home"
      url_for(only_path: true, action: action, anchor: anchor)
    else
      "##{anchor}"
    end
  end

  def content_policy_subsection_items
    content_tag(:li, link_to(t("home.tos_toc.content.offensive_content"), tos_anchor_url("content", "II.A"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.fanworks"), tos_anchor_url("content", "II.B"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.commercial_promotion"), tos_anchor_url("content", "II.C"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.copyright_infringement"), tos_anchor_url("content", "II.D"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.plagiarism"), tos_anchor_url("content", "II.E"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.personal_information_and_fannish_identities"), tos_anchor_url("content", "II.F"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.impersonation"), tos_anchor_url("content", "II.G"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.harassment"), tos_anchor_url("content", "II.H"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.user_icons"), tos_anchor_url("content", "II.I"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.mandatory_tags"), tos_anchor_url("content", "II.J"))) +
      content_tag(:li, link_to(t("home.tos_toc.content.illegal_and_inappropriate_content"), tos_anchor_url("content", "II.K")))
  end

  def privacy_policy_subsection_items
    content_tag(:li, link_to(t("home.tos_toc.privacy.applicability"), tos_anchor_url("privacy", "III.A"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.scope_of_personal_information_we_process"), tos_anchor_url("privacy", "III.B"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.types_of_personal_information_we_collect_and_process"), tos_anchor_url("privacy", "III.C"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.aggregate_and_anonymous_information"), tos_anchor_url("privacy", "III.D"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.your_rights_under_applicable_data_privacy_laws"), tos_anchor_url("privacy", "III.E"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.information_shared_with_third_parties"), tos_anchor_url("privacy", "III.F"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.termination_of_account"), tos_anchor_url("privacy", "III.G"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.retention_of_personal_information"), tos_anchor_url("privacy", "III.H"))) +
      content_tag(:li, link_to(t("home.tos_toc.privacy.contact_us"), tos_anchor_url("privacy", "III.I")))
  end

  def tos_subsection_items
    content_tag(:li, link_to(t("home.tos_toc.tos.general_terms"), tos_anchor_url("tos", "I.A"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.updates_to_the_tos"), tos_anchor_url("tos", "I.B"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.potential_problems"), tos_anchor_url("tos", "I.C"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.content_you_access"), tos_anchor_url("tos", "I.D"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.what_we_do_with_content"), tos_anchor_url("tos", "I.E"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.what_you_cant_do"), tos_anchor_url("tos", "I.F"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.registration_and_email_addresses"), tos_anchor_url("tos", "I.G"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.age_policy"), tos_anchor_url("tos", "I.H"))) +
      content_tag(:li, link_to(t("home.tos_toc.tos.abuse_policy"), tos_anchor_url("tos", "I.I")))
  end
end
