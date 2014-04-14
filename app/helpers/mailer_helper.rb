module MailerHelper

  def style_bold(text)
    ("<b style=\"color:#990000\">" + "#{text}".html_safe + "</b>").html_safe
  end
  
  def style_link(body, url, html_options = {})
    html_options[:style] = "color:#990000"
    link_to(body.html_safe, url, html_options)
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
    style_link(text, "http://opendoors.transformativeworks.org/contact/open%20doors")
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
  
end # end of MailerHelper