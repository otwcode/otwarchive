module RelatedWorksHelper
  def related_work_title(related_work)
    work_link = link_to related_work.title, polymorphic_url(related_work)

    if related_work.respond_to?(:unrevealed?) && related_work.unrevealed?
      t("related_works.index.unrevealed_work")
    elsif related_work.restricted? && !logged_in?
      t("related_works.index.restricted_work")
    else
      work_link
    end
  end

  def related_work_title_with_byline(related_work)
    work_link = link_to related_work.title, polymorphic_url(related_work)
    creator_link = byline(related_work)

    if related_work.respond_to?(:unrevealed?) && related_work.unrevealed?
      t("related_works.index.unrevealed_work")
    elsif related_work.restricted? && !logged_in?
      t("related_works.index.restricted_work_by_html", creator_link: creator_link)
    else
      t("related_works.index.revealed_work_by_html",
        work_link: work_link,
        creator_link: creator_link)
    end
  end

  def related_work_relation(related_work, relation)
    work_link = link_to related_work.title, polymorphic_url(related_work)

    if related_work.respond_to?(:unrevealed?) && related_work.unrevealed?
      t(".#{relation}.unrevealed")
    elsif related_work.restricted? && !logged_in?
      t(".#{relation}.restricted")
    else
      t(".#{relation}.revealed_html", work_link: work_link)
    end
  end
end
