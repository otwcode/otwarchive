# frozen_string_literal: true

# A class for calculating the filters that should be on a particular
# filterable, and updating the FilterTaggings to match.
#
# Operates in bulk to try to work faster.
class FilterUpdater
  include AfterCommitEverywhere

  attr_reader :klass, :type, :ids, :queue

  # Takes as argument the type of filterable that we're modifying, the list of
  # IDs of filterables that we're modifying, and the priority of the current
  # change. (The priority, queue, is not actually used in this class. It's just
  # passed along to the filterable class through reindex_for_filter_changes.)
  def initialize(type, ids, queue)
    @type = type.to_s
    @ids = ids.to_a
    @queue = queue

    @klass = [Work, ExternalWork].find { |klass| klass.to_s == @type }

    unless @klass
      raise "FilterCalculator type '#{type}' not allowed."
    end

    @modified = []
  end

  ########################################
  # DELAY CALCULATIONS WITH RESQUE
  ########################################

  @queue = :utilities

  # Put this object on the Resque queue so that update will be called later.
  def async_update
    Resque.enqueue(self.class, type, ids, queue)
  end

  # Perform for Resque.
  def perform(type, ids, queue)
    FilterUpdater.new(type, ids, queue).update
  end

  ########################################
  # COMPUTE INFO
  ########################################

  # Calculate what the filters should be for every valid item in the batch, and
  # updates the existing FilterTaggings to match.
  def update
    FilterTagging.transaction do
      load_info

      filter_taggings_by_id = FilterTagging.where(
        filterable_type: type, filterable_id: valid_item_ids
      ).group_by(&:filterable_id)

      valid_item_ids.each do |id|
        update_filters_for_item(id, filter_taggings_by_id[id] || [])
      end
    end

    # Even if we're inside a nested transaction, the asynchronous steps
    # required by reindexing should always take place outside of the
    # transaction.
    after_commit { reindex_changed }
  end

  private

  # Calculate what the filters should be for a particular item, and perform the
  # updates needed to ensure that those are the current filter taggings. Takes
  # as argument the ID of the item to update, and the list of filter_taggings
  # for that item.
  def update_filters_for_item(item_id, filter_taggings)
    missing_direct = Set.new(direct_filters[item_id])
    missing_inherited = Set.new(inherited_filters[item_id])

    filter_taggings.each do |ft|
      if missing_direct.delete?(ft.filter_id)
        update_inherited(ft, false)
      elsif missing_inherited.delete?(ft.filter_id)
        update_inherited(ft, true)
      else
        destroy(ft)
      end
    end

    create_multiple(item_id, missing_direct, false)
    create_multiple(item_id, missing_inherited, true)
  end

  # Notify the filterable class about the changes that we made, so that it can
  # perform the appropriate steps to reindex everything.
  def reindex_changed
    klass.reindex_for_filter_changes(valid_item_ids, @modified, queue)
  end

  ########################################
  # RETRIEVE INFO FROM DATABASE
  ########################################

  # Calculates direct_filters, meta_tags, and inherited_filters for this batch
  # of items.
  def load_info
    valid_item_ids
    direct_filters
    meta_tags
    inherited_filters
  end

  # Restrict the IDs so that we don't try to create FilterTaggings for items
  # that have been deleted.
  def valid_item_ids
    @valid_item_ids ||= klass.unscoped.where(id: ids).distinct.pluck(:id)
  end

  # Calculates what the direct filters should be for this batch of items.
  # Returns a hash mapping from item IDs to a list of direct filter IDs (that
  # is, filters that the item is either directly tagged with, or tagged with
  # one of its synonyms).
  def direct_filters
    return @direct_filters if @direct_filters

    taggings = Tagging.where(taggable_type: type, taggable_id: valid_item_ids)

    filter_relations = [
      Tag.canonical.joins(:taggings),
      Tag.canonical.joins(:mergers => :taggings)
    ]

    pairs = filter_relations.flat_map do |filters|
      filters.merge(taggings).pluck("taggings.taggable_id", "tags.id")
    end

    @direct_filters = hash_from_pairs(pairs)
  end

  # Calculates what all of the meta tags are for all of the filters that should
  # appear on items in this batch.
  def meta_tags
    return @meta_tags if @meta_tags

    all_filters = direct_filters.values.flatten.uniq
    pairs = Tag.canonical.joins(:sub_taggings).where(
      meta_taggings: { sub_tag_id: all_filters }
    ).pluck(:sub_tag_id, :meta_tag_id)

    @meta_tags = hash_from_pairs(pairs)
  end

  # Uses direct_filters and meta_tags to calculate what the inherited filters
  # should be for each of the items in this batch.
  def inherited_filters
    return @inherited_filters if @inherited_filters

    @inherited_filters = Hash.new([].freeze)

    @direct_filters.each_pair do |item_id, filter_ids|
      inherited = filter_ids.flat_map { |filter_id| meta_tags[filter_id] }
      @inherited_filters[item_id] = (inherited - filter_ids).uniq
    end

    @inherited_filters
  end

  # Given a list of pairs of IDs, treat each pair as a (key, value) pair, and
  # return a hash that associates each key with a list of values. Sets the
  # default value of the hash to an empty frozen list.
  def hash_from_pairs(pairs)
    hash = Hash.new([].freeze)

    pairs.uniq.each do |key, value|
      hash[key] = [] unless hash.key?(key)
      hash[key] << value
    end

    hash
  end

  ########################################
  # CHANGE FILTERS AND RECORD
  ########################################

  # Create multiple FilterTaggings for the same item, with the given
  # filter_ids. Records the new item in the list @modified.
  def create_multiple(item_id, filter_ids, inherited)
    filter_ids.each do |filter_id|
      @modified << FilterTagging.create(filter_id: filter_id,
                                        filterable_type: type,
                                        filterable_id: item_id,
                                        inherited: inherited)
    end
  end

  # Modify an existing filter tagging, and record the modified item in the list
  # @modified.
  def update_inherited(filter_tagging, inherited)
    return if filter_tagging.inherited == inherited
    filter_tagging.update(inherited: inherited)
    @modified << filter_tagging
  end

  # Destroy an existing filter tagging, and record the modified item in
  # the list @modified.
  def destroy(filter_tagging)
    filter_tagging.destroy
    @modified << filter_tagging
  end
end
