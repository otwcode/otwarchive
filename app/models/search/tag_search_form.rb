class TagSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query,
    :name,
    :wrangling_status,
    :fandoms,
    :type,
    :created_at,
    :uses,
    :sort_column,
    :sort_direction
  ].freeze

  attr_accessor :options

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(options={})
    @options = options
    set_fandoms
    set_canonical
    set_filterable
    @searcher = TagQuery.new(@options.delete_if { |_, v| v.blank? })
  end

  def persisted?
    false
  end

  def search_results
    @searcher.search_results
  end

  def set_canonical
    if @options[:wrangling_status] == "canonical"
      @options[:canonical] = "T"
    elsif %w[noncanonical synonymous].include?(@options[:wrangling_status])
      @options[:canonical] = "F"
    end
  end

  def set_filterable
    if %w[synonymous canonical_synonymous].include?(@options[:wrangling_status])
      @options[:filterable] = "T"
    elsif @options[:wrangling_status] == "noncanonical_nonsynonymous"
      @options[:filterable] = "F"
    end
  end

  def set_fandoms
    return if @options[:fandoms].blank?

    names = @options[:fandoms].split(",").map(&:squish)
    @options[:fandom_ids] = Tag.where(name: names).pluck(:id)
  end

  def sort_columns
    options[:sort_column] || "name"
  end

  def sort_direction
    options[:sort_direction] || default_sort_direction
  end

  def sort_options
    [
      %w[Name name],
      ["Date Created", "created_at"],
      %w[Uses uses]
    ]
  end

  def default_sort_direction
    %w[created_at uses].include?(sort_column) ? "desc" : "asc"
  end
end
