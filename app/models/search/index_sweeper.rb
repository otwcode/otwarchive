class IndexSweeper

  def self.async_cleanup(klass, expected_ids, found_ids)
    deleted_ids = expected_ids.map(&:to_i).select { |id| !found_ids.include?(id) }

    if deleted_ids.any?
      AsyncIndexer.index(klass, deleted_ids, "cleanup")
    end
  end

end
