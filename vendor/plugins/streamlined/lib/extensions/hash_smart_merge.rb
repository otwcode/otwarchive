module HashSmartMerge
  # Merges hashes one level deep without overwriting keys. If the same
  # key exists in both hashes, the values will be put in an array.
  def smart_merge!(hash)
    hash.each_pair do |k, v|
      if has_key?(k)
        self[k] = [self[k]] << v
      else
        self[k] = v
      end
    end
    self
  end
end

Hash.send(:include, HashSmartMerge)