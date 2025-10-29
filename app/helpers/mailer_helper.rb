module MailerHelper

  def style_bold(text)
    ("<b style=\"color:#990000\">" + "#{text}".html_safe + "</b>").html_safe
  end

  def style_link(body, url, html_options = {})
    html_options[:style] = "color:#990000"
    link_to(body.html_safe, url, html_options)
  end

  def style_role(text)
    tag.em(tag.strong(text))
  end

  # For work, chapter, and series links
  def style_creation_link(title, url, html_options = {})
    html_options[:style] = "color:#990000"
    ("<i><b>" + link_to(title.html_safe, url, html_options) + "</b></i>").html_safe
  end

  # For work, chapter, and series titles
  def style_creation_title(title)
    ("<i><b style=\"color:#990000\">" + title.html_safe + "</b></i>").html_safe
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

  def tos_link(text)
    style_link(text, tos_url)
  end

  def opendoors_link(text)
    style_link(text, "https://opendoors.transformativeworks.org/contact-open-doors/")
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

  # The title used in creatorship_notification and creatorship_request
  # emails.
  def creation_title(creation)
    if creation.is_a?(Chapter)
      t("mailer.general.creation.title_with_chapter_number",
         position: creation.position, title: creation.work.title)
    else
      creation.title
    end
  end

  # e.g., Title (x words), where Title is a link
  def creation_link_with_word_count(creation, creation_url)
    title = if creation.is_a?(Chapter)
              creation.full_chapter_title.html_safe
            else
              creation.title.html_safe
            end
    t("mailer.general.creation.link_with_word_count",
      creation_link: style_creation_link(title, creation_url),
      word_count: creation_word_count(creation)).html_safe
  end

  # e.g., "Title" (x words), where Title is not a link
  def creation_title_with_word_count(creation)
    title = if creation.is_a?(Chapter)
              creation.full_chapter_title.html_safe
            else
              creation.title.html_safe
            end
    t("mailer.general.creation.title_with_word_count",
      creation_title: title, word_count: creation_word_count(creation))
  end

  # TODO: Update all mailers to use creator_links or creator_text as
  # appropriate to eliminate pseuds.map { etc }.to_sentence in the views. Note
  # that these should never be used on anonymous creations. Text dealing with
  # Anonymous creations should always have a separate translation, as in the
  # creation_attribution_ and batch_subscription_subject methods below.
  def creator_links(creation)
    to_sentence(creation.pseuds.map { |p| style_pseud_link(p) })
  end

  def creator_text(creation)
    to_sentence(creation.pseuds.map { |p| text_pseud(p) })
  end

  # "by name" or "by name, name, and name", which appears under or after
  # creation titles.
  # It's always plain text if the creation is anonymous, so we share that
  # translation between two methods.
  def creation_attribution_links(creation)
    if creation.anonymous?
      t("mailer.general.creation.attribution.anon")
    else
      t("mailer.general.creation.attribution.named.html", creator_links: creator_links(creation))
    end
  end

  def creation_attribution_text(creation)
    if creation.anonymous?
      t("mailer.general.creation.attribution.anon")
    else
      t("mailer.general.creation.attribution.named.text", creators: creator_text(creation))
    end
  end

  def metadata_label(text)
    text.html_safe + t("mailer.general.metadata_label_indicator")
  end

  # Spacing is dealt with in locale files, e.g. " : " for French.
  def work_tag_metadata(tags)
    return if tags.empty?

    "#{work_tag_metadata_label(tags)}#{work_tag_metadata_list(tags)}"
  end

  def style_metadata_label(text)
    style_bold(metadata_label(text))
  end

  # Spacing is dealt with in locale files, e.g. " : " for French.
  def style_work_tag_metadata(tags)
    return if tags.empty?

    label = style_bold(work_tag_metadata_label(tags))
    "#{label}#{style_work_tag_metadata_list(tags)}".html_safe
  end

  # The subject of batch_subscription_notification is based on the first
  # creation in the email. It uses that creation's creator, so if you subscribe
  # to user X, who has co-created a work with user Y, and Y posts a chapter that
  # is not co-created, the subject line will say just "Y posted" even though the
  # subscription is for X.
  # Note that we assume this is being used in batch_subscription_notification,
  # after a subscription.valid_notification_entry?(creation) check. You can
  # otherwise pass invalid or anonymity-breaking combinations of data to this.
  def batch_subscription_subject(subscription, creation, additional_creations_count)
    work = creation.is_a?(Chapter) ? creation.work : creation
    series = subscription.subscribable if subscription.subscribable_type == "Series"

    base_key = %i[user_mailer batch_subscription_notification subject]
    translation_keys = base_key.dup
    translation_keys << (creation.anonymous? ? :anon : :named)
    translation_keys << :series if series
    translation_keys << creation.model_name.i18n_key
    translation_keys << (additional_creations_count.zero? ? :one_entry : :multiple_entries)

    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.anon.chapter.multiple_entries")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.anon.chapter.one_entry")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.anon.series.chapter.multiple_entries")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.anon.series.chapter.one_entry")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.anon.series.work.multiple_entries")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.anon.series.work.one_entry")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.chapter.multiple_entries")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.chapter.one_entry")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.series.chapter.multiple_entries")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.series.chapter.one_entry")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.series.work.multiple_entries")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.series.work.one_entry")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.work.multiple_entries")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.named.work.one_entry")
    computed_key = translation_keys.join(".")

    unless creation.anonymous?
      creator_list = creation.pseuds.map(&:byline).to_sentence
      # For pluralization: creator publicó, creator y creator2 publicaron.
      creators_count = creation.pseuds.size
    end
    chapter_position = creation.position if creation.is_a?(Chapter)
    unless additional_creations_count.zero?
      # "and X more," translated separately so we can pluralize "more" based on X.
      # i18n-tasks-use t("user_mailer.batch_subscription_notification.subject.more")
      more_translation = t(base_key.dup.push(:more).join("."), count: additional_creations_count)
    end

    interpolations = {
      app_name: ArchiveConfig.APP_SHORT_NAME,
      creators: creator_list,
      count: creators_count,
      chapter_position: chapter_position,
      work_title: work.title,
      series_title: series&.title,
      more: more_translation
    }

    t(computed_key, **interpolations)
  end

  def batch_subscription_text_preface(creation)
    work = creation.is_a?(Chapter) ? creation.work : creation

    interpolations = {}
    unless creation.anonymous?
      interpolations[:creators] = creator_text(work)
      # For pluralization: creator publicó, creator y creator2 publicaron.
      interpolations[:count] = work.pseuds.size
    end
    interpolations[:work_title_with_word_count] = creation_title_with_word_count(work) if creation.is_a?(Chapter)

    t(batch_subscription_preface_key(creation, email_format: :text), **interpolations)
  end

  def batch_subscription_html_preface(creation)
    work = creation.is_a?(Chapter) ? creation.work : creation

    interpolations = {}
    unless creation.anonymous?
      interpolations[:creator_links] = creator_links(work)
      # For pluralization: creator publicó, creator y creator2 publicaron.
      interpolations[:count] = work.pseuds.size
    end
    interpolations[:work_link_with_word_count] = creation_link_with_word_count(work, work_url(work)) if creation.is_a?(Chapter)

    t(batch_subscription_preface_key(creation, email_format: :html), **interpolations)
  end

  def commenter_pseud_or_name_link(comment)
    return style_bold(t("roles.anonymous_creator")) if comment.by_anonymous_creator?

    if comment.comment_owner.nil?
      t("roles.commenter_name.html", name: style_bold(comment.comment_owner_name), role_with_parens: style_role(t("roles.guest_with_parens")))
    else
      role = comment.user.official ? t("roles.official_with_parens") : t("roles.registered_with_parens")
      pseud_link = style_link(comment.pseud.byline, user_pseud_url(comment.user, comment.pseud))
      t("roles.commenter_name.html", name: tag.strong(pseud_link), role_with_parens: style_role(role))
    end
  end

  def commenter_pseud_or_name_text(comment)
    return t("roles.anonymous_creator") if comment.by_anonymous_creator?

    if comment.comment_owner.nil?
      t("roles.commenter_name.text", name: comment.comment_owner_name, role_with_parens: t("roles.guest_with_parens"))
    else
      role = comment.user.official ? t("roles.official_with_parens") : t("roles.registered_with_parens")
      t("roles.commenter_name.text", name: text_pseud(comment.pseud), role_with_parens: role)
    end
  end

  def content_for_commentable_text(comment)
    if comment.ultimate_parent.is_a?(Tag)
      t(".content.tag.text",
        pseud: commenter_pseud_or_name_text(comment),
        tag: comment.ultimate_parent.commentable_name,
        tag_url: tag_url(comment.ultimate_parent))
    elsif comment.parent.is_a?(Chapter) && comment.ultimate_parent.chaptered?
      if comment.parent.title.blank?
        t(".content.chapter.untitled_text",
          pseud: commenter_pseud_or_name_text(comment),
          chapter_position: comment.parent.position,
          work: comment.ultimate_parent.commentable_name,
          chapter_url: work_chapter_url(comment.parent.work, comment.parent))
      else
        t(".content.chapter.titled_text",
          pseud: commenter_pseud_or_name_text(comment),
          chapter_position: comment.parent.position,
          chapter_title: comment.parent.title,
          work: comment.ultimate_parent.commentable_name,
          chapter_url: work_chapter_url(comment.parent.work, comment.parent))
      end
    else
      t(".content.other.text",
        pseud: commenter_pseud_or_name_text(comment),
        title: comment.ultimate_parent.commentable_name,
        commentable_url: polymorphic_url(comment.ultimate_parent))
    end
  end

  def content_for_commentable_html(comment)
    if comment.ultimate_parent.is_a?(Tag)
      t(".content.tag.html",
        pseud_link: commenter_pseud_or_name_link(comment),
        tag_link: style_link(comment.ultimate_parent.commentable_name, tag_url(comment.ultimate_parent)))
    elsif comment.parent.is_a?(Chapter) && comment.ultimate_parent.chaptered?
      t(".content.chapter.html",
        pseud_link: commenter_pseud_or_name_link(comment),
        chapter_link: style_link(comment.parent.title.blank? ? t(".chapter.untitled", position: comment.parent.position) : t(".chapter.titled", position: comment.parent.position, title: comment.parent.title), work_chapter_url(comment.parent.work, comment.parent)),
        work_link: style_creation_link(comment.ultimate_parent.commentable_name, work_url(comment.parent.work)))
    else
      t(".content.other.html",
        pseud_link: commenter_pseud_or_name_link(comment),
        commentable_link: style_creation_link(comment.ultimate_parent.commentable_name, polymorphic_url(comment.ultimate_parent)))
    end
  end

  def collection_footer_note_html(is_collection_email, collection)
    if is_collection_email
      t("mailer.collections.why_collection_email.html",
        collection_link: style_footer_link(collection.title, collection_url(collection)))
    else
      t("mailer.collections.why_maintainer.html",
        collection_link: style_footer_link(collection.title, collection_url(collection)))
    end
  end

  def collection_footer_note_text(is_collection_email, collection)
    if is_collection_email
      t("mailer.collections.why_collection_email.text",
        collection_title: collection.title,
        collection_url: collection_url(collection))
    else
      t("mailer.collections.why_maintainer.text",
        collection_title: collection.title,
        collection_url: collection_url(collection))
    end
  end

  private

  # e.g., 1 word or 50 words
  def creation_word_count(creation)
    t("mailer.general.creation.word_count", count: creation.word_count)
  end

  def work_tag_metadata_label(tags)
    return if tags.empty?

    # i18n-tasks-use t('activerecord.models.archive_warning')
    # i18n-tasks-use t('activerecord.models.character')
    # i18n-tasks-use t('activerecord.models.fandom')
    # i18n-tasks-use t('activerecord.models.freeform')
    # i18n-tasks-use t('activerecord.models.rating')
    # i18n-tasks-use t('activerecord.models.relationship')
    type = tags.first.type
    t("activerecord.models.#{type.underscore}", count: tags.count) + t("mailer.general.metadata_label_indicator")
  end

  # We don't use .to_sentence because these aren't links and we risk making any
  # connector word (e.g., "and") look like part of the final tag.
  def work_tag_metadata_list(tags)
    return if tags.empty?

    tags.pluck(:name).join(t("support.array.words_connector"))
  end

  def style_work_tag_metadata_list(tags)
    return if tags.empty?

    type = tags.first.type
    # Fandom tags are linked and to_sentence'd.
    if type == "Fandom"
      to_sentence(tags.map { |f| style_link(f.name, fandom_url(f)) })
    else
      work_tag_metadata_list(tags)
    end
  end

  def batch_subscription_preface_key(creation, email_format:)
    translation_keys = %i[user_mailer batch_subscription_notification preface]
    translation_keys << (creation.anonymous? ? :anon : :named)
    translation_keys << creation.model_name.i18n_key
    translation_keys << (creation.backdate ? :backdated : :new) if creation.is_a?(Work)
    translation_keys << email_format unless creation.is_a?(Work) && creation.anonymous?

    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.anon.chapter.html")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.anon.chapter.text")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.anon.work.backdated")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.anon.work.new")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.named.chapter.html")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.named.chapter.text")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.named.work.backdated.html")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.named.work.backdated.text")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.named.work.new.html")
    # i18n-tasks-use t("user_mailer.batch_subscription_notification.preface.named.work.new.text")
    translation_keys.join(".")
  end
end
