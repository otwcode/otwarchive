class WorkSearchCleanser

  # For various reasons, some options come in needing processing/cleanup
  # before we use them for searching. May be indicative of code that needs
  # cleaning up elsewhere in the app.
  def self.clean(options)
    new(options).clean
  end

  attr_accessor :options

  def initialize(options)
    @options = options || {}
  end

  def clean
    set_parent_fields!
    set_tag_fields!
    set_sorting!
    set_language!
    clean_up_angle_brackets

    # Clean up blank options from forms
    options.delete_if { |key, value| value.blank? }
  end

  private

  def set_parent_fields!
    parent = options[:work_parent]
    case parent
    when Tag
      options[:filter_ids] ||= []
      options[:filter_ids] << parent.id
    when Pseud
      options[:pseud_ids] = [parent.id]
    when User
      options[:pseud_ids] = parent.pseuds.pluck(:id)
    when Collection
      options[:collection_ids] = [parent.id]
    end
  end

  # We get tag info in as strings, ids and arrays
  def set_tag_fields!
    # Possible to have a single id or an array
    if options[:rating_ids].present?
      options[:rating_ids] = [options[:rating_ids]].flatten
    end

    # Associate tag names with specific tags where possible
    # to allow for precise filtering
    options[:tag] ||= ""
    %w(fandom character relationship freeform other_tag).each do |tag_type|
      tag_names_key = "#{tag_type}_names".to_sym
      if options[tag_names_key].present?
        names = options[tag_names_key].split(",")
        tags = Tag.where(name: names, canonical: true)
        unless tags.empty?
          options[:filter_ids] ||= []
          options[:filter_ids] += tags.map{ |tag| tag.id }
        end
        leftovers = names - tags.map{ |tag| tag.name }
        options[:tag] << leftovers.join(" ") + " "
      end
    end
  end

  # Clean up sorting column and direction
  # Don't impose sorting on unsorted searches
  def set_sorting!
    return unless options[:faceted] || options[:collected] || options[:sort_column].present?

    unless sort_values.include?(options[:sort_column])
      options[:sort_column] = 'revised_at'
    end

    options[:sort_direction] ||= default_sort_direction(options[:sort_column]).downcase
    options[:sort_direction] = "desc" unless options[:sort_direction] == "asc"
  end

  # Translate language abbreviations to numerical ids
  def set_language!
    if options[:language_id].present? && options[:language_id].to_i == 0
      language = Language.find_by(short: options[:language_id])
      if language.present?
        options[:language_id] = language.id
      end
    end
  end


  def clean_up_angle_brackets
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at, :query].each do |countable|
      if options[countable].present?
        options[countable].gsub!("&gt;", ">")
        options[countable].gsub!("&lt;", "<")
      end
    end
  end

  #############################################################################
  #
  # SORTING
  #
  #############################################################################

  def sort_options
    QueryCleaner::SORT_OPTIONS
  end

  def sort_values
    sort_options.map{ |option| option.last }
  end

  # extract the pretty name
  def name_for_sort_column(sort_column)
    Hash[sort_options.collect {|v| [ v[1], v[0] ]}][sort_column]
  end

  def default_sort_direction(sort_column)
    if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
      'asc'
    else
      'desc'
    end
  end

end
