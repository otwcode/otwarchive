class TagSweeper < ActionController::Caching::Sweeper
  observe Tag
  
  def after_create(tag)
    if tag.canonical
      tag.add_to_autocomplete
    end
  end
  
  def after_update(tag)
    if tag.changed.include?(:canonical)
      if tag.canonical
        # newly canonical tag
        tag.add_to_autocomplete
      else
        tag.remove_from_autocomplete
      end
    end
  end

  def before_destroy(tag)
    if Tag::USER_DEFINED.include?(tag.type) && tag.canonical
      tag.remove_from_autocomplete
    end
  end
  
  private

end