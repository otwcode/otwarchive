class BookmarkSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query,
    :rec,
    :bookmark_notes,
    :with_notes,
    :date,
    :show_private,
    :pseud_ids,
    :user_ids,
    :bookmarker,
    :bookmarkable_pseud_names,
    :bookmarkable_pseud_ids,
    :bookmarkable_type,
    :tag,
    :excluded_tag_names,
    :excluded_tag_ids,
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
    :page,
    :faceted
  ]

  attr_accessor :options

  def self.count_for_user(user)
    BookmarkQuery.new(user_ids: [user.id]).count
  end

  def self.count_for_pseuds(pseuds)
    BookmarkQuery.new(pseud_ids: pseuds.map(&:id)).count
  end

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(options={})
    @options = options
    [:date, :bookmarkable_date].each do |countable|
      if @options[countable].present?
        @options[countable].gsub!("&gt;", ">")
        @options[countable].gsub!("&lt;", "<")
      end
    end

    # If we call the form field 'notes', the parser adds html to it
    @options[:notes] = @options[:bookmark_notes]
    @searcher = BookmarkQuery.new(options.delete_if { |k, v| v.blank? })
  end

  def persisted?
    false
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
      tags << Tag.where(id: all_tag_ids).pluck(:name).join(", ")
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

  def search_results
    @searcher.search_results
  end

  ###############
  # SORTING
  ###############

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
