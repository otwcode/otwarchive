module WranglingHelper
  def tag_counts_per_category
    counts = {}
    [Fandom, Character, Relationship, Freeform].each do |klass|
      counts[klass.to_s.downcase.pluralize.to_sym] = Rails.cache.fetch("/wrangler/counts/sidebar/#{klass}", race_condition_ttl: 10, expires_in: 1.hour) do
        TagQuery.new({
          type: klass.to_s,
          to_wrangle: true
        }).count
      end
    end
    counts[:UnsortedTag] = Rails.cache.fetch("/wrangler/counts/sidebar/UnsortedTag", race_condition_ttl: 10, expires_in: 1.hour) do
      UnsortedTag.count
    end
    counts
  end
end
