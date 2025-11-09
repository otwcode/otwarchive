# frozen_string_literal: true

class TagDecorator < SimpleDelegator
  COMMON_COLUMNS = [:id, :created_at, :updated_at, :name, :canonical, :merger_id, :sortable_name, :unwrangleable].freeze

  attr_accessor :data

  def initialize(delegate, data)
    super(delegate)
    @data = data
  end

  def to_param
    Tag.to_param(self.name)
  end

  def self.load_from_elasticsearch(hits, **options)
    return Tag.load_from_elasticsearch(hits, **options) unless options[:scopes]&.include?(:es_only)

    hits.map { it["_source"].transform_keys(&:to_sym) }
      .map { |doc| TagDecorator.new(doc[:tag_type].classify.constantize.new(doc.slice(*COMMON_COLUMNS)).freeze, doc) }
  end
end
