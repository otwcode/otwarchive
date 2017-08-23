class WorkSearchForm < SearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query,
    :title,
    :creators,
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
    :excluded_tag_names,
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
    :page
  ]

  attr_accessor :options

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(opts={})
    @options = self.options = process_options(opts)
    @searcher = WorkQuery.new(@options.delete_if { |k, v| v.blank? })
  end

  def process_options(opts = {})
    opts[:creator] = opts[:creators] if opts[:creators]
    opts.delete :creators

    WorkSearch.new(opts).options
  end

  def persisted?
    false
  end

  def summary
    summary = []
    if @options[:query].present?
      summary << @options[:query]
    end
    if @options[:title].present?
      summary << "Title: #{@options[:title]}"
    end
    if @options[:creators].present?
      summary << "Author/Artist: #{@options[:creators]}"
    end
    tags = []
    if @options[:tag].present?
      tags << @options[:tag]
    end
    all_tag_ids = []
    [:filter_ids, :fandom_ids, :rating_ids, :category_ids, :warning_ids, :character_ids, :relationship_ids, :freeform_ids].each do |tag_ids|
      if @options[tag_ids].present?
        all_tag_ids += @options[tag_ids]
      end
    end
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

  def sort_column
    @sort_column || 'revised_at'
  end

  def sort_direction
    @sort_direction || default_sort_direction
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
