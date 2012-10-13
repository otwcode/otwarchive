class WorkSearch < Search
  
  serialized_options :query, 
    :title, 
    :creator, 
    :revised_at, 
    :language_id, 
    :complete, 
    :single_chapter,
    :word_count, 
    :hits, 
    :kudos_count, 
    :bookmarks_count, 
    :comments_count, 
    :pseud_ids,
    :collection_ids,
    :tag,
    :other_tag_names,
    :filter_ids,
    :fandom_names,
    :fandom_ids,
    :rating_ids,
    :category_ids,
    :warning_ids,
    :character_names,
    :character_ids,
    :relationship_names,
    :relationship_ids,
    :freeform_names,
    :freeform_ids,
    :sort_column,
    :show_restricted,
    :page
    
  attr_accessor :works_parent, :faceted
  
  after_initialize :process_options
  
  # For various reasons, some options come in needing processing/cleanup
  # before we use them for searching. May be indicative of code that needs
  # cleaning up elsewhere in the app.
  def process_options
    self.options ||= {}
    
    self.set_parent_fields!
    self.set_tag_fields!
    self.set_sorting!
    self.set_visibility!
    self.set_language!
    self.clean_up_angle_brackets
    
    # Clean up blank options from forms
    self.options.delete_if { |key, value| value.blank? }
  end
  
  # Search for works based on options
  # Note that tire redefines 'self' for the scope of the method
  def search_results
    self.options ||= {}
    search_opts = self.options
    search_text = generate_search_text
    include_facets = self.faceted
    
    Work.tire.search(page: search_opts[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE, load: true) do
      query do
        boolean do
          must { string search_text, default_operator: "AND" } if search_text.present?
          
          must { term :posted, 'T' }
          must { term :restricted, 'F' } unless search_opts[:show_restricted]
          must { term :complete, 'T' } if %w(1 true).include?(search_opts[:complete].to_s)
          must { term :expected_number_of_chapters, 1 } if %w(1 true).include?(search_opts[:single_chapter].to_s)
          must { term :in_unrevealed_collection, 'F' } unless search_opts[:show_unrevealed]
          must { term :in_anon_collection, 'F' } unless search_opts[:show_anon]
          must { term :language_id, search_opts[:language_id].to_i } if search_opts[:language_id].present?
          
          if search_opts[:pseud_ids].present?
            must { terms :pseud_ids, search_opts[:pseud_ids] }
          end
          
          [:filter_ids, :rating_ids, :warning_ids, :category_ids, :fandom_ids, :character_ids, :relationship_ids, :freeform_ids, :collection_ids].each do |id_list|
            if search_opts[id_list].present?
              search_opts[id_list].each do |id|
                must { term id_list, id }
              end
            end
          end
        end
      end
      
      [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
        if search_opts[countable].present?
          filter :range, countable => Search.range_to_search(search_opts[countable])
        end
      end
      
      if search_opts[:sort_column].present?
        sort { by search_opts[:sort_column], search_opts[:sort_direction] }
      end

      if include_facets
        %w(rating warning category fandom character relationship freeform).each do |facet_type|
          facet facet_type do
            terms "#{facet_type}_ids".to_sym
          end
        end
      end
    end
  end
  
  def set_parent_fields!
    if self.works_parent.present?
      if self.works_parent.is_a?(Tag)
        options[:filter_ids] ||= []
        options[:filter_ids] << works_parent.id
      elsif self.works_parent.is_a?(Pseud)
        options[:pseud_ids] = [self.works_parent.id]
      elsif self.works_parent.is_a?(User)
        options[:pseud_ids] = self.works_parent.pseuds.value_of(:id)
      elsif self.works_parent.is_a?(Collection)
        options[:collection_ids] = [self.works_parent.id]
      end
    end
  end
  
  # We get tag info in as strings, ids and arrays
  def set_tag_fields!
    # Possible to have a single id or an array
    if options[:rating_ids].present?
      options[:rating_ids] = [options[:rating_ids]].flatten
    end
    
    # Handle a single fandom id
    if options[:fandom_id]
      options[:fandom_ids] ||= []
      options[:fandom_ids] << options[:fandom_id]
    end
    
    # Associate tag names with specific tags where possible
    # to allow for precise filtering
    options[:tag] ||= ""
    %w(fandom character relationship freeform other_tag).each do |tag_type|
      tag_names_key = "#{tag_type}_names".to_sym
      if options[tag_names_key].present?
        names = options[tag_names_key].split(",")
        tags = Tag.where(:name => names, :canonical => true)
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
    return unless faceted || options[:sort_column].present?
    
    unless sort_values.include?(options[:sort_column])
      options[:sort_column] = 'revised_at'
    end
    
    options[:sort_direction] = sort_direction(options[:sort_column]).downcase
  end
  
  # Don't show anonymous works on user/pseud pages
  # Only show unrevealed works on collection pages
  def set_visibility!
    if self.works_parent.present? && %w(Pseud User).include?(self.works_parent.class.to_s)
      options[:show_anon] = false
    else
      options[:show_anon] = true
    end
    
    if self.works_parent.present? && self.works_parent.is_a?(Collection)
      options[:show_unrevealed] = true
    else
      options[:show_unrevealed] = false
    end
  end
  
  # Translate language abbreviations to numerical ids
  def set_language!
    if options[:language_id].present? && options[:language_id].to_i == 0
      language = Language.find_by_short(options[:language_id])
      if language.present?
        options[:language_id] = language.id
      end
    end
  end
  
  # Search within text fields: general, titles, creator names, and partial tag names
  def generate_search_text
    search_text = self.query.present? ? self.query.dup : ""
    [:title, :creator, :tag].each do |field|
      if self.options[field].present?
        self.options[field].split(" ").each do |word|
          if word[0] == "-"
            search_text << " NOT "
            word.slice!(0)
          end
          word = escape_reserved_characters(word)
          search_text << " #{field.to_s}:#{word.downcase}"
        end
      end
    end
    search_text
  end
  
  def clean_up_angle_brackets
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
      if options[countable].present?
        options[countable].gsub!("&gt;", ">")
        options[countable].gsub!("&lt;", "<")
      end
    end
  end
  
  def escape_reserved_characters(word)
    word.gsub!('!', '\\!')
    word.gsub!('+', '\\+')
    word.gsub!('-', '\\-')
    word.gsub!('?', '\\?')
    word.gsub!("~", '\\~')
    word.gsub!("(", '\\(')
    word.gsub!(")", '\\)')
    word.gsub!("[", '\\[')
    word.gsub!("]", '\\]')
    word.gsub!(':', '\\:')
    word
  end
  
  def summary
    summary = []
    if options[:query].present?
      summary << options[:query]
    end
    if options[:title].present?
      summary << "Title: #{options[:title]}"
    end
    if options[:creator].present?
      summary << "Creator: #{options[:creator]}"
    end
    tags = []
    if options[:tag].present?
      tags << options[:tag]
    end
    [:filter_ids, :fandom_ids, :rating_ids, :category_ids, :warning_ids, :character_ids, :relationship_ids, :freeform_ids].each do |tag_ids|
      if options[tag_ids].present?
        tags << Tag.where(:id => options[tag_ids]).value_of(:name).join(", ")
      end
    end
    unless tags.empty?
      summary << "Tags: #{tags.join(", ")}"
    end
    if %w(1 true).include?(self.complete.to_s)
      summary << "Complete"
    end
    if options[:language_id].present?
      language = Language.find_by_id(options[:language_id])
      if language.present?
        summary << "Language: #{language.name}"
      end
    end
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
      if options[countable].present?
        summary << "#{countable.to_s.humanize}: #{options[countable]}"
      end
    end
    summary.join(", ")
  end
  
  #############################################################################
  #
  # SORTING
  #
  #############################################################################
  def sort_options
    [
      ['Author', 'authors_to_sort_on'],
      ['Title', 'title_to_sort_on'],
      ['Date Posted', 'created_at'],
      ['Date Updated', 'revised_at'],
      ['Word Count', 'word_count'],
      ['Hits', 'hits'],
      ['Kudos', 'kudos_count'],
      ['Comments', 'comments_count'],
      ['Bookmarks', 'bookmarks_count']
    ]
  end
  
  def sort_values
    sort_options.map{ |option| option.last }
  end
  
  def sort_direction(sort_column)
    if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
      'asc'
    else
      'desc'
    end
  end
  
end
