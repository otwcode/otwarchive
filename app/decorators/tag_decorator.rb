# frozen_string_literal: true

class TagDecorator < SimpleDelegator
  # tag_type is used to specify the type of the created delegate
  COMMON_COLUMNS = [:id, :created_at, :updated_at, :name, :canonical, :merger_id, :sortable_name, :unwrangleable].freeze

  attr_accessor :data

  def initialize(data)
    super(data[:tag_type].classify.constantize.new(data.slice(*COMMON_COLUMNS)).freeze)
    @data = data
  end

  def to_param
    Tag.to_param(self.name)
  end

  def has_posted_works? # rubocop:disable Naming/PredicateName
    data[:has_posted_works]
  end

  def taggings_count_cache
    data[:uses]
  end

  def unwrangled?
    data[:unwrangled]
  end

  def self.load_from_elasticsearch(hits, **options)
    return Tag.load_from_elasticsearch(hits, **options) unless options[:scopes]&.include?(:es_only)

    hits.map { it["_source"].transform_keys(&:to_sym) }
      .map { |doc| TagDecorator.new(doc) }
  end
end
