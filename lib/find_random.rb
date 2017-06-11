module FindRandom
  def self.append_features(base)
    def base.find_random
      count = self.count
      return nil if count == 0
      offset = rand(count)
      self.find(:first, offset: offset)
    end
  end
end
