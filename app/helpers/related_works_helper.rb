module RelatedWorksHelper
  def related_works_count(user)
    related_works = user.related_works.visible_on_user_page(user).visible_works
    parent_work_relationships = user.parent_work_relationships.visible_on_user_page(user)
    local_parent_work_relationships = parent_work_relationships.of_visible_local_works
    external_parent_work_relationships = parent_work_relationships.of_visible_external_works

    return related_works.count + local_parent_work_relationships.count + external_parent_work_relationships.count
  end
end
