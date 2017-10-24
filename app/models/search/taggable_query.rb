# Shared methods for work and bookmark queries
module TaggableQuery

  def filter_ids
    return @filter_ids if @filter_ids.present?
    @filter_ids = options[:filter_ids] || []
    %w(fandom rating warning category character relationship freeform).each do |tag_type|
      if options["#{tag_type}_ids".to_sym].present?
        ids = options["#{tag_type}_ids".to_sym]
        @filter_ids += ids.is_a?(Array) ? ids : [ids]
      end
    end
    @filter_ids += named_tags
    @filter_ids.uniq
  end

  def exclusion_ids
    return @exclusion_ids if @exclusion_ids.present?
    return if options[:excluded_tag_names].blank? && options[:excluded_tag_ids].blank?
    names = options[:excluded_tag_names].split(",") if options[:excluded_tag_names]
    excluded_tags = []

    if names
      excluded_tags = Tag.where(name: names)
    end
    if options[:excluded_tag_ids]
      excluded_tags += Tag.where(id: options[:excluded_tag_ids])
    end
    if excluded_tags.find{ |tag| tag.merger_id.present? }
      excluded_tags += Tag.where(id: excluded_tags.map(&:merger_id).compact.uniq)
    end
    ids = excluded_tags.pluck(:id)
    if excluded_tags.present?
      child_ids = CommonTagging.joins("JOIN tags ON tags.id = common_taggings.filterable_id").
                           where("filterable_id IN (?) AND tags.type = 'Character'", ids).
                           pluck(:common_tag_id)
      ids = (ids + child_ids).uniq
    end
    @exclusion_ids = ids
  end

  # Get the ids for tags passed in by name
  def named_tags
    names = []
    %w(fandom character relationship freeform other_tag).each do |tag_type|
      tag_names_key = "#{tag_type}_names".to_sym
      if options[tag_names_key].present?
        names += options[tag_names_key].split(",")
      end
    end
    Tag.where(name: names, canonical: true).pluck(:id)
  end

end