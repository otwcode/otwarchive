class TagSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query,
    :name,
    :canonical,
    :fandom_names,
    :fandom_ids,
    :type,
    :created_at,
    :uses,
    :sort_column
  ]

  attr_accessor :options

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(options={})
    @options = options
    @searcher = TagQuery.new(@options.delete_if { |_, v| v.blank? })
  end

  def persisted?
    false
  end

  def search_results
    @searcher.search_results
  end

  def sort_columns
    options[:sort_column] || "name"
  end

  def sort_options
    [
      %w[Name name],
      %w[Date Created created_at],
      %w[Uses uses]
    ]
  end
end
