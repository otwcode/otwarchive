module RelatedWorksHelper
  def related_work_title(related_work, with_byline: false, relation: "other_relations")
    work_link = link_to related_work.title, polymorphic_url(related_work)
    creator_link = byline(related_work)

    if related_work.respond_to?(:unrevealed?) && related_work.unrevealed?
      t("related_works.index.unrevealed")
    elsif related_work.restricted? && !logged_in?
      if with_byline
        t(".#{relation}.restricted_by_html", creator_link: creator_link)
      else
        t(".#{relation}.restricted")
      end
    elsif with_byline
      t(".#{relation}.revealed_html", work_link: work_link, creator_link: creator_link)
    else
      work_link
    end
  end
end
