module MailerHelper

  def style_bold(text)
    ("<b style=\"color:#990000\">" + "#{text}".html_safe + "</b>").html_safe
  end

  def style_link(body, url, html_options = {})
    html_options[:style] = "color:#990000"
    link_to(body.html_safe, url, html_options)
  end

  # For work, chapter, and series titles
  def style_creation_link(title, url, html_options = {})
    html_options[:style] = "color:#990000"
    ("<i><b>" + link_to(title.html_safe, url, html_options) + "</b></i>").html_safe
  end

  def style_footer_link(body, url, html_options = {})
    html_options[:style] = "color:#FFFFFF"
    link_to(body.html_safe, url, html_options)
  end

  def style_email(email, name = nil, html_options = {})
    html_options[:style] = "color:#990000"
    mail_to(email, name.nil? ? nil : name.html_safe, html_options)
  end

  def style_pseud_link(pseud)
    style_link("<img src=\"" + root_url + "favicon.ico\" style=\"border:none;display:inline-block;font-weight:bold;height:16px;padding-right:3px;vertical-align:-3px;width:16px;\">" +
      pseud.byline, user_pseud_url(pseud.user, pseud))
  end

  def text_pseud(pseud)
    pseud.byline + " (#{user_pseud_url(pseud.user, pseud)})"
  end

  def style_quote(text)
    ("<blockquote style=\"background:#eee;margin:1em;padding:8px;\">" + text + "</blockquote>").html_safe
  end

  def support_link(text)
    style_link(text, root_url + "support")
  end

  def abuse_link(text)
    style_link(text, root_url + "abuse_reports/new")
  end

  def opendoors_link(text)
    style_link(text, "http://opendoors.transformativeworks.org/contact-open-doors/")
  end

  def styled_divider
    ("<div style=\"line-height:0.5em;\">" +
      "<br>" +
      "<hr style=\"color:transparent;background-color: transparent;border-bottom: 1px solid #DDDDDD;\">" +
    "</div><br>").html_safe
  end

  def text_divider
    "--------------------"
  end

  # strip opening paragraph tags, and line breaks or close-pargraphs at the end of the string
  # all other close-paragraphs become double line breaks
  # line break tags become single line breaks
  # bold text is wrapped in *
  # italic text is wrapped in /
  # underlined text is wrapped in _
  # all other html tags are stripped
  def to_plain_text(html)
    strip_tags(
      html.gsub(/<p>|<\/p>\z|<br( ?\/)?>\z/, "")
        .gsub(/<\/p>/, "\n\n")
        .gsub(/<br( ?\/)?>/, "\n")
        .gsub(/<\/?(b|em|strong)>/, "*")
        .gsub(/<\/?(i|cite)>/, "/")
        .gsub(/<\/?u>/, "_")
    )
  end

  # Reformat a string as HTML with <br> tags instead of newlines, but with all
  # other HTML escaped.
  # This is used for collection.assignment_notification, which already strips
  # HTML tags (when saving the collection settings, the params are sanitized),
  # but that still leaves other HTML entities.
  def escape_html_and_create_linebreaks(html)
    # Escape each line with h(), then join with <br>s and mark as html_safe to
    # ensure that the <br>s aren't escaped.
    html.split("\n").map { |line_of_text| h(line_of_text) }.join('<br>').html_safe
  end

  # The title used in creatorship_notification and creatorship_invitation
  # emails.
  def creation_title(creation)
    if creation.is_a?(Chapter)
      ts("Chapter %{position} of %{title}",
         position: creation.position, title: creation.work.title)
    else
      creation.title
    end
  end

  # The bylines used in subscription emails to prevent exposing the name(s) of
  # anonymous creator(s).
  def creator_links(work)
    if work.anonymous?
      "Anonymous"
    else
      work.pseuds.map { |p| style_pseud_link(p) }.to_sentence.html_safe
    end
  end

  def creator_text(work)
    if work.anonymous?
      "Anonymous"
    else
      work.pseuds.map { |p| text_pseud(p) }.to_sentence.html_safe
    end
  end

  def user_manage_collection_items_link(user, collection_item)
    url = user_manage_collection_items_url(user, collection_item)
    style_link(user_manage_collection_items_page_name(collection_item), url) 
  end

  def user_manage_collection_items_url(user, collection_item)
    user_collection_items_url(user,
      status: user_collection_item_status(collection_item))
  end

  def user_manage_collection_items_page_name(collection_item)
    status = user_collection_item_status(collection_item)
    t("mailer_helper.user_manage_collection_items_page_name.#{status}")
  end

  def user_collection_item_status(collection_item)
    if collection_item.unreviewed_by_user?
      "unreviewed_by_user"
    elsif collection_item.rejected_by_user?
      "rejected_by_user"
    # It's not unreviewed or rejected by the user, so#
    # collection_item.approved_by_user? is implied.
    elsif collection_item.approved_by_collection?
      "approved"
    elsif collection_item.rejected_by_collection?
      "rejected_by_collection"
    elsif collection_item.unreviewed_by_collection?
      "unreviewed_by_collection"
    end
  end
end # end of MailerHelper
