# frozen_string_literal: true

# A helper class for calculating inherited meta taggings.
class InheritedMetaTagUpdater
  attr_reader :base, :boundary, :all

  def initialize(base)
    @base = base
    @boundary = [base.id]
    @all = [base.id]
  end

  # Advance to the next depth of our breadth-first search.
  def advance
    return if done?

    @boundary = MetaTagging.where(
      direct: true,
      sub_tag_id: @boundary
    ).pluck(:meta_tag_id) - @all

    @all += @boundary
  end

  # Check whether we're done finding all of our inherited meta tags.
  def done?
    @boundary.empty?
  end

  # Go through the breadth-first search steps to figure out what this tag's
  # inherited meta tags should be.
  def calculate
    advance until done?
  end

  # Generate the missing inherited meta taggings and delete the ones that are
  # no longer needed.
  def update
    calculate

    missing = Set.new(all)
    missing.delete(base.id)

    # Delete the unnecessary meta taggings.
    base.meta_taggings.each do |mt|
      unless missing.delete?(mt.meta_tag_id)
        # We weren't missing it, so as long as it's not a direct meta tagging,
        # we don't need it anymore.
        mt.destroy unless mt.direct
      end
    end

    # Build the missing meta taggings.
    Tag.where(id: missing.to_a).each do |tag|
      base.meta_taggings.create(direct: false, meta_tag: tag)
    end
  end

  # Fixes inherited meta tags for all tags with at least one meta tagging.
  def self.update_all
    Tag.joins(:meta_taggings).distinct.find_each do |tag|
      new(tag).update

      # Yield each tag to allow for progress messages.
      yield tag if block_given?
    end
  end
end
