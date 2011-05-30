module AutocompleteSource
  REDIS_DELIMITER = ": "

  # override to define any redis prefix spaces where this object should live
  def redis_prefixes
    ["autocomplete_#{self.class.name.downcase}"]
  end
    
  def redis_search_string
    "#{name}"
  end
  
  def redis_value
    "#{id}#{REDIS_DELIMITER}#{name}" + (self.respond_to?(:title) ? "#{REDIS_DELIMITER}#{title}" : "")
  end
  
  def redis_score
    0
  end
  
  def add_to_redis(score = nil)
    score = redis_score unless score
    redis_search_string.three_letter_sections.each do |section|
      redis_prefixes.each do |prefix|
        $redis.zadd(prefix+"_"+section, score, redis_value)
      end
    end
  end
  
  def remove_from_redis
    redis_search_string.three_letter_sections.each do |section|
      redis_prefixes.each do |prefix|
        $redis.zrem(prefix+"_"+section, redis_value)
      end
    end
  end
  
  module ClassMethods
    def parse_redis_value(current_redis_value)
      current_redis_value.split(REDIS_DELIMITER, 3)
    end
  
    def fullname_from_redis(current_redis_value)
      current_redis_value.split(REDIS_DELIMITER, 2)[1]
    end
  
    def id_from_redis(current_redis_value)
      parse_redis_value(current_redis_value)[0]
    end
  
    def name_from_redis(current_redis_value)
      parse_redis_value(current_redis_value)[1]
    end
  
    def title_from_redis(current_redis_value)
      parse_redis_value(current_redis_value)[2]
    end
  
    def redis_lookup(search_param, redis_prefix, options = {:sort => "down"})
      redis_key = redis_prefix + "_#{search_param}"
      redis_key += "_#{options[:extra_sets].join("_")}" if options[:extra_sets]
      if search_param.length > 3
        sets = options[:extra_sets] || []
        sets += search_param.three_letter_sections.map {|section| "#{redis_prefix}_#{section}"}
        $redis.zinterstore(redis_key, sets, :aggregate => :max)
        $redis.expire(redis_key, 60*ArchiveConfig.AUTOCOMPLETE_EXPIRATION_TIME)
      end
      options[:sort] == "down" ? $redis.zrevrange(redis_key, 0, -1) : $redis.zrange(redis_key, 0, -1)
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
end