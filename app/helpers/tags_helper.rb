module TagsHelper
  def tag_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t.taggings_count.to_i if t.taggings_count.to_i > max
      min = t.taggings_count.to_i if t.taggings_count.to_i < min
    }
  
    divisor = ((max - min) / classes.size) + 1
  
    tags.each { |t|
      yield t, classes[(t.taggings_count - min) / divisor]
    }
  end
  
  
  def tag_wrangler_footer
    render :partial => 'tag_wranglings/footer'
  end
end
