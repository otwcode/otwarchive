module RelatedWorksHelper
  def related_works_count(user)
    related_works = user.related_works.for_user_page(user)
    parent_work_relationships = user.parent_work_relationships.for_user_page(user)

    related_works.count + parent_work_relationships.count
  end
end
