class WorkSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query,
    :title,
    :creators,
    :collected,
    :faceted,
    :revised_at,
    :language_id,
    :complete,
    :crossover,
    :single_chapter,
    :word_count,
    :hits,
    :kudos_count,
    :bookmarks_count,
    :comments_count,
    :pseud_ids,
    :collection_ids,
    :tag,
    :excluded_tag_names,
    :excluded_tag_ids,
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
    :date_from,
    :date_to,
    :words_from,
    :words_to,
    :sort_column,
    :sort_direction,
    :page
  ]

  attr_accessor :options

  # Make a direct request to the elasticsearch count api
  def self.count_for_user(user)
    WorkQuery.new(user_ids: [user.id]).count
  end

  def self.count_for_pseuds(pseuds)
    WorkQuery.new(pseud_ids: pseuds.map(&:id)).count
  end

  def self.user_count(user)
    cached_count(user) || count_for_user(user)
  end

  def self.pseud_count(pseud)
    cached_count(pseud) || count_for_pseuds([pseud])
  end

  def self.cached_count(owner)
    status = User.current_user ? 'logged_in' : 'logged_out'
    key = "#{owner.works_index_cache_key}_#{status}_page"
    works = Rails.cache.read(key)
    if works.present?
      works.total_entries
    end
  end

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(opts={})
    @options = self.options = process_options(opts)
    @searcher = WorkQuery.new(@options.delete_if { |k, v| v.blank? })
  end

  def process_options(opts = {})
    # TODO: Should be able to remove this
    opts[:creator] = opts[:creators] if opts[:creators]
    opts[:creators] = opts[:creator] if opts[:creator]

    opts.keys.each do |key|
      if opts[key] == "0"
        opts[key] = nil
      end
    end

    opts[:query].gsub!('creator:', 'creators:') if opts[:query]

    # TODO: Change this to not rely on WorkSearch
    processed_opts = WorkSearch.new(opts).options
    processed_opts.merge!(collected: opts[:collected], faceted: opts[:faceted])
    processed_opts
  end

  def persisted?
    false
  end

  def summary
    summary = []
    if @options[:query].present?
      summary << @options[:query].gsub('creators:', 'creator:')
    end
    if @options[:title].present?
      summary << "Title: #{@options[:title]}"
    end
    if @options[:creators].present?
      summary << "Author/Artist: #{@options[:creators]}"
    end
    tags = @searcher.included_tag_names
    all_tag_ids = @searcher.filter_ids
    unless all_tag_ids.empty?
      tags << Tag.where(id: all_tag_ids).pluck(:name).join(", ")
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
    if @options[:language_id].present?
      language = Language.find_by(id: @options[:language_id])
      if language.present?
        summary << "Language: #{language.name}"
      end
    end
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
      if @options[countable].present?
        summary << "#{countable.to_s.humanize.downcase}: #{@options[countable]}"
      end
    end
    if @options[:sort_column].present?
      summary << "sort by: #{name_for_sort_column(@options[:sort_column]).downcase}" +
        (@options[:sort_direction].present? ?
          (@options[:sort_direction] == "asc" ? " ascending" : " descending") : "")
    end
    summary.join(" ")
  end

  def search_results
    @searcher.search_results
  end

  ###############
  # SORTING
  ###############

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

  def sort_columns
    return 'revised_at' if options[:sort_column].blank?

    options[:sort_column]
  end

  def sort_direction
    return default_sort_direction if options[:sort_direction].blank?

    options[:sort_direction]
  end

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

  def default_sort_direction
    if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
      'asc'
    else
      'desc'
    end
  end

end
