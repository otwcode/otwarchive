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
    set_wrangling_status
    @searcher = TagQuery.new(@options.delete_if { |_, v| v.blank? })
  end

  def persisted?
    false
  end

  def search_results
    @searcher.search_results
  end

  def set_wrangling_status
    case @options[:wrangling_status]
    when "canonical"
      @options[:canonical] = "T"
    when "noncanonical"
      @options[:canonical] = "F"
    when "synonymous"
      @options[:canonical] = "F"
      @options[:canonical_or_synonymous] = "T"
    when "canonical_synonymous"
      @options[:canonical_or_synonymous] = "T"
    when "noncanonical_nonsynonymous"
      @options[:canonical_or_synonymous] = "F"
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
