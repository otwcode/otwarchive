module TagsHelper
  def tag_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t.taggings_count if t.taggings_count > max
      min = t.taggings_count if t.taggings_count < min
    }
  
    divisor = ((max - min) / classes.size) + 1
  
    tags.each { |t|
      yield t, classes[(t.taggings_count - min) / divisor]
    }
  end
end
