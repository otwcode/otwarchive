class BookmarkSearch < Search
  
  serialized_options :query, 
    :rec,
    :notes,
    :with_notes,
    :date,
    :show_private,
    :pseud_ids,
    :bookmarker, 
    :bookmarkable_pseud_names, 
    :bookmarkable_pseud_ids, 
    :bookmarkable_type,    
    :tag, 
    :other_tag_names,
    :tag_ids, 
    :filter_ids,
    :filter_names, 
    :fandom_ids, 
    :character_ids, 
    :relationship_ids, 
    :freeform_ids, 
    :rating_ids, 
    :warning_ids, 
    :category_ids, 
    :bookmarkable_title, 
    :bookmarkable_date,
    :bookmarkable_complete, 
    :bookmarkable_language_id, 
    :collection_ids, 
    :bookmarkable_collection_ids,
    :sort_column,
    :show_restricted,
    :page
    
  attr_accessor :bookmarks_parent, :faceted
  
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
    include_facets = self.faceted
    
    response = Bookmark.tire.search(page: search_opts[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE) do
      query do
        boolean do
          must { string search_text, default_operator: "AND" } if search_text.present?
          
          must { term :private, 'F' } unless search_opts[:show_private]
          must { term :hidden_by_admin, 'F' }
          must { term :rec, 'T' } if %w(1 true).include?(search_opts[:rec].to_s)
          must { term :with_notes, 'T' } if %w(1 true).include?(search_opts[:with_notes].to_s)

          must { term :bookmarkable_posted, 'T' }
          must { term :bookmarkable_hidden, 'F' }
          must { term :bookmarkable_restricted, 'F' } unless search_opts[:show_restricted]
          must { term :bookmarkable_complete, 'T' } if %w(1 true).include?(search_opts[:complete].to_s)
          must { term :bookmarkable_language_id, search_opts[:language_id].to_i } if search_opts[:language_id].present?
          must { term :bookmarkable_type, search_opts[:bookmarkable_type].gsub(" ", "").downcase} if search_opts[:bookmarkable_type].present?
          
          if search_opts[:pseud_ids].present?
            must { terms :pseud_id, search_opts[:pseud_ids] }
          end
          
          [:rating_ids, :warning_ids, :category_ids, :fandom_ids, :character_ids, :relationship_ids, :freeform_ids].each do |id_list|
            if search_opts[id_list].present?
              search_opts[:filter_ids] ||= []
              search_opts[:filter_ids] += search_opts[id_list]
            end
          end
          
          [:filter_ids, :tag_ids, :collection_ids, :bookmarkable_collection_ids].each do |id_list|
            if search_opts[id_list].present?
              search_opts[id_list].each do |id|
                must { term id_list, id }
              end
            end
          end
        end
      end
      
      [:bookmarkable_word_count, :date, :bookmarkable_date].each do |countable|
        if search_opts[countable].present?
          key = (countable == :date) ? :created_at : countable
          filter :range, key => Search.range_to_search(search_opts[countable])
        end
      end
      
      if search_opts[:sort_column].present?
        sort { by search_opts[:sort_column], search_opts[:sort_direction] }
      end

      if include_facets
        %w(tag rating warning category fandom character relationship freeform).each do |facet_type|
          facet facet_type do
            terms "#{facet_type}_ids".to_sym
          end
        end
      end
    end
    SearchResult.new('Bookmark', response)
  end
  
  def set_parent_fields!
    if self.bookmarks_parent.present?
      if self.bookmarks_parent.is_a?(Tag)
        options[:filter_ids] ||= []
        options[:filter_ids] << bookmarks_parent.id
      elsif self.bookmarks_parent.is_a?(Pseud)
        options[:pseud_ids] = [self.bookmarks_parent.id]
      elsif self.bookmarks_parent.is_a?(User)
        options[:pseud_ids] = self.bookmarks_parent.pseuds.value_of(:id)
      elsif self.bookmarks_parent.is_a?(Collection)
        options[:collection_ids] = [self.bookmarks_parent.id]
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
      options[:sort_column] = 'created_at'
    end
    
    options[:sort_direction] = sort_direction(options[:sort_column]).downcase
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
  
  # Search within text fields: general, notes, bookmarker names, and partial tag names
  def generate_search_text
    search_text = self.query.present? ? escape_slashes(self.query.dup) : ""
    [:bookmarker, :notes, :tag].each do |field|
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
    [:date, :bookmarkable_date].each do |countable|
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
    if options[:bookmarker].present?
      summary << "Bookmarker: #{options[:bookmarker]}"
    end
    if options[:notes].present?
      summary << "Notes: #{options[:notes]}"
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
    if self.bookmarkable_type.present?
      summary << "Type: #{self.bookmarkable_type}"
    end
    if %w(1 true).include?(self.rec.to_s)
      summary << "Rec"
    end
    if %w(1 true).include?(self.with_notes.to_s)
      summary << "With Notes"
    end
    [:date, :bookmarkable_date].each do |countable|
      if options[countable].present?
        desc = (countable == :date) ? "Date bookmarked" : "Date updated"
        summary << "#{desc}: #{options[countable]}"
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
      ['Date Bookmarked', 'created_at'],
      ['Date Updated', 'bookmarkable_date'],
    ]
  end
  
  def sort_values
    sort_options.map{ |option| option.last }
  end
  
  def sort_direction(sort_column)
    'desc'
  end
  
end

