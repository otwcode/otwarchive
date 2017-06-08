class TagSweeper < ActionController::Caching::Sweeper
  observe Tag

  def after_create(tag)
    if tag.canonical
      tag.add_to_autocomplete
    end
    update_tag_nominations(tag)
  end

  def after_update(tag)
    if tag.canonical_changed?
      if tag.canonical
        # newly canonical tag
        tag.add_to_autocomplete
      else
        # decanonicalised tag
        tag.remove_from_autocomplete
      end
    elsif tag.canonical
      # clean up the autocomplete
      tag.remove_stale_from_autocomplete
      tag.add_to_autocomplete
    end

    # Expire caching when a merger is added or removed
    if tag.merger_id_changed?
      if tag.merger_id_was.present?
        old = Tag.find(tag.merger_id_was)
        old.update_works_index_timestamp!
      end
      if tag.merger_id.present?
        tag.merger.update_works_index_timestamp!
      end
    end

    # if type has changed, expire the tag's parents' children cache (it stores the children's type)
    if tag.type_changed?
      tag.parents.each do |parent_tag|
        ActionController::Base.new.expire_fragment("views/tags/#{parent_tag.id}/children")
      end
    end

    update_tag_nominations(tag)
  end

  def before_destroy(tag)
    if Tag::USER_DEFINED.include?(tag.type) && tag.canonical
      tag.remove_from_autocomplete
    end
    update_tag_nominations(tag, deleted=true)
  end

  private

  def update_tag_nominations(tag, deleted=false)
    values = {}
    if deleted
      values[:canonical] = false
      values[:exists] = false
      values[:parented] = false
      values[:synonym] = nil
    else
      values[:canonical] = tag.canonical
      values[:synonym] = tag.merger.nil? ? nil : tag.merger.name
      values[:parented] = tag.parents.any? {|p| p.is_a?(Fandom)}
      values[:exists] = true
    end
    TagNomination.where(tagname: tag.name).update_all(values)
  end


end
