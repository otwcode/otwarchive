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
    :sort_direction,
    :show_restricted,
    :page
    
  attr_accessor :works_parent, :faceted, :collected
  
  after_initialize :process_options
  
  # For various reasons, some options come in needing processing/cleanup
  # before we use them for searching. May be indicative of code that needs
  # cleaning up elsewhere in the app.
  def process_options
    self.options ||= {}
    
    self.set_parent_fields!
    self.set_tag_fields!
    self.set_sorting!
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
    facet_tags = self.faceted
    facet_collections = self.collected
    work_search = self
    
    response = Work.tire.search(page: search_opts[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE) do
      query do
        boolean do
          must { string search_text, default_operator: "AND" } if search_text.present?
          
          must { term :posted, 'T' } unless work_search.should_include_drafts?
          must { term :hidden_by_admin, 'F' }
          must { term :restricted, 'F' } unless search_opts[:show_restricted]
          must { term :complete, 'T' } if %w(1 true).include?(search_opts[:complete].to_s)
          must { term :expected_number_of_chapters, 1 } if %w(1 true).include?(search_opts[:single_chapter].to_s)
          must { term :in_unrevealed_collection, 'F' } unless work_search.should_include_unrevealed?
          must { term :in_anon_collection, 'F' } unless work_search.should_include_anon?
          must { term :language_id, search_opts[:language_id].to_i } if search_opts[:language_id].present?
          
          if search_opts[:pseud_ids].present?
            must { terms :pseud_ids, search_opts[:pseud_ids] }
          end
          
          [:rating_ids, :warning_ids, :category_ids, :fandom_ids, :character_ids, :relationship_ids, :freeform_ids].each do |id_list|
            if search_opts[id_list].present?
              search_opts[:filter_ids] ||= []
              search_opts[:filter_ids] += search_opts[id_list]
            end
          end
          
          [:filter_ids, :collection_ids].each do |id_list|
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

      if facet_collections
        facet 'collections' do
          terms "collection_ids".to_sym, size: 50
        end
      end

      if facet_tags
        %w(rating warning category fandom character relationship freeform).each do |facet_type|
          facet facet_type do
            terms "#{facet_type}_ids".to_sym
          end
        end
      end
    end
    SearchResult.new('Work', response)
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
    return unless faceted || collected || options[:sort_column].present?
    
    unless sort_values.include?(options[:sort_column])
      options[:sort_column] = 'revised_at'
    end
    
    options[:sort_direction] ||= sort_direction(options[:sort_column]).downcase
    options[:sort_direction] = "desc" unless options[:sort_direction] == "asc"
  end

  # Should include anonymous works unless we're on a user or pseud page
  # OR unless the user is viewing their own collected works
  def should_include_anon?
    self.works_parent.blank? || 
    !%w(Pseud User).include?(self.works_parent.class.to_s) ||
    (self.collected && (User.current_user == self.works_parent))
  end

  def should_include_unrevealed?
    self.works_parent.present? && (self.works_parent.is_a?(Collection) || self.collected)
  end

  def should_include_drafts?
    self.collected && User.current_user.present? && (User.current_user == self.works_parent)
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
    search_text = self.query.present? ? escape_slashes(self.query.dup) : ""
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
    if self.options[:collection_ids].blank? && self.collected
      search_text << " collection_ids:*"
    end
    search_text
  end
  
  def clean_up_angle_brackets
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at, :query].each do |countable|
      if options[countable].present?
        options[countable].gsub!("&gt;", ">")
        options[countable].gsub!("&lt;", "<")
      end
    end
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
      summary << "Author/Artist: #{options[:creator]}"
    end
    tags = []
    if options[:tag].present?
      tags << options[:tag]
    end
    all_tag_ids = []
    [:filter_ids, :fandom_ids, :rating_ids, :category_ids, :warning_ids, :character_ids, :relationship_ids, :freeform_ids].each do |tag_ids|
      if options[tag_ids].present?
        all_tag_ids += options[tag_ids]
      end
    end
    unless all_tag_ids.empty?
      tags << Tag.where(:id => all_tag_ids).value_of(:name).join(", ")
    end
    unless tags.empty?
      summary << "Tags: #{tags.uniq.join(", ")}"
    end
    if %w(1 true).include?(self.complete.to_s)
      summary << "Complete"
    end
    if %w(1 true).include?(self.single_chapter.to_s)
      summary << "Single Chapter"
    end
    if options[:language_id].present?
      language = Language.find_by_id(options[:language_id])
      if language.present?
        summary << "Language: #{language.name}"
      end
    end
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
      if options[countable].present?
        summary << "#{countable.to_s.humanize.downcase}: #{options[countable]}"
      end
    end
    if options[:sort_column].present?
      summary << "sort by: #{name_for_sort_column(options[:sort_column]).downcase}" + 
        (options[:sort_direction].present? ? 
          (options[:sort_direction] == "asc" ? " ascending" : " descending") : "")
    end
    summary.join(" ")
  end
  
  #############################################################################
  #
  # SORTING
  #
  #############################################################################
  
  SORT_OPTIONS = [
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
  
  def sort_options
    SORT_OPTIONS
  end
  
  def sort_values
    sort_options.map{ |option| option.last }
  end
  
  # extract the pretty name
  def name_for_sort_column(sort_column)
    Hash[SORT_OPTIONS.collect {|v| [ v[1], v[0] ]}][sort_column]
  end
  
  def sort_direction(sort_column)
    if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
      'asc'
    else
      'desc'
    end
  end
  
end

