# frozen_string_literal: true

# A module used for determining if a set of given fandoms is considered a "crossover"
class FandomCrossover
  # An item with multiple fandoms which are not related
  # to one another can be considered a crossover
  def check_for_crossover(fandoms)
    # Short-circuit the check if there's only one fandom tag:
    return false if fandoms.count == 1

    # Replace fandoms with their mergers if possible,
    # as synonyms should have no meta tags themselves
    all_without_syns = fandoms.map { |f| f.merger || f }.uniq

    # For each fandom, find the set of all meta tags for that fandom (including
    # the fandom itself).
    meta_tag_groups = all_without_syns.map do |f|
      # TODO: This is more complicated than it has to be. Once the
      # meta_taggings table is fixed so that the inherited meta-tags are
      # correctly calculated, this can be simplified.
      boundary = [f] + f.meta_tags
      all_meta_tags = []

      until boundary.empty?
        all_meta_tags.concat(boundary)
        boundary = boundary.flat_map(&:meta_tags).uniq - all_meta_tags
      end

      all_meta_tags.uniq
    end

    # Two fandoms are "related" if they share at least one meta tag. A work is
    # considered a crossover if there is no single fandom on the work that all
    # the other fandoms on the work are "related" to.
    meta_tag_groups.none? do |meta_tags1|
      meta_tag_groups.all? do |meta_tags2|
        (meta_tags1 & meta_tags2).any?
      end
    end
  end
end
