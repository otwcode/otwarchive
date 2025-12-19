module SupportNoticeHelper
  def css_classes_for_support_notice(notice)
    [notice.support_notice_type, "notice", "userstuff"].uniq.join(" ")
  end
end
