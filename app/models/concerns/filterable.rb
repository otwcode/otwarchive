# frozen_string_literal: true

# A module for types that are supposed to have FilterTaggings, calculated based
# on their tags. Includes Taggable.
module Filterable
  extend ActiveSupport::Concern
  include Taggable

  included do
    has_many :filter_taggings, as: :filterable, inverse_of: :filterable
    has_many :filters, through: :filter_taggings

    has_many :direct_filter_taggings,
             -> { where(inherited: false) },
             class_name: "FilterTagging",
             as: :filterable
    has_many :direct_filters,
             source: :filter,
             through: :direct_filter_taggings
  end

  # Update filters for this particular filterable.
  def update_filters
    FilterUpdater.new(self.class.base_class, [id], :main).update
  end

  class_methods do
    # Update the filters for all filterables in this relation.
    def update_filters(async_update: false,
                       reindex_queue: :background,
                       job_queue: :utilities)
      batch_size = ArchiveConfig.FILTER_UPDATE_BATCH_SIZE

      select(:id).find_in_batches(batch_size: batch_size) do |batch|
        updater = FilterUpdater.new(base_class, batch.map(&:id), reindex_queue)

        if async_update
          updater.async_update(job_queue: job_queue)
        else
          updater.update
        end

        # Allow for progress messages in long-running updates.
        yield if block_given?
      end
    end

    # This is the callback that gets called when FilterUpdater is done with a
    # single batch of Filterables of this type. Designed to reindex all of the
    # Filterables whose filters changed. It's called in after_commit, to
    # minimize issues with stale data.
    #
    # The _ids argument isn't used here, but is used in some of the subclasses.
    def reindex_for_filter_changes(_ids, filter_taggings, queue)
      changed_ids = filter_taggings.map(&:filterable_id)
      IndexQueue.enqueue_ids(base_class, changed_ids, queue)
    end
  end

  ################
  # SEARCH
  ################

  # Restricted tags (which are in the general list but not the public one) only
  # really apply to series, as works are either fully restricted or fully public.
  # We define the various visibility-based methods to be the same here, and they are
  # overridden in the Series class to account for tags on restricted works in the series.
  %w[general public].each do |visibility|
    define_method("#{visibility}_tags") do
      (tags.pluck(:name) + filters.pluck(:name)).uniq
    end

    # Index all the filters for pulling works
    define_method("#{visibility}_filter_ids") do
      (tags.pluck(:id) + filters.pluck(:id)).uniq
    end

    # Index only direct filters (non meta-tags) for facets
    define_method("#{visibility}_filters_for_facets") do
      cache_variable = "@filters_for_facets_#{visibility}"
      instance_variable_set(cache_variable, direct_filters.to_a) unless instance_variable_defined?(cache_variable)
      instance_variable_get(cache_variable)
    end

    Tag::FILTERS.each do |tag_type|
      define_method("#{visibility}_#{tag_type.underscore}_ids") do
        send("#{visibility}_filters_for_facets")
          .select { |tag| tag.type.to_s == tag_type }
          .map(&:id)
      end
    end
  end
end
