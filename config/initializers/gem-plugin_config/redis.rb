require 'radix'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../../..'
rails_env = ENV['RAILS_ENV'] || 'development'

redis_config = YAML.load_file(rails_root + '/config/redis.yml')
redis_host, redis_port = redis_config[rails_env].split(":")
$redis = Redis.new(:host => redis_host, :port => redis_port)

class String
  def three_letter_sections
    # split string into all possible three-letter sections
    three_letter_sections = []
    letters = self.split(//) 
    while letters.size > 3
      three_letter_sections << letters[0..2].join('')
      letters.shift
    end
    three_letter_sections << letters.join('')
  end
end

# load tags and pseuds in three-letter sections into a sorted set in the database if they don't already exist
# based on Playdar's method as described in http://simonwillison.net/static/2010/redis-tutorial/
unless $redis.getset("autocomplete_data_loaded", "1") == "1"
  # load up canonical user-defined tags
  Tag::USER_DEFINED.each do |type|
    type.classify.constantize.visible_to_all_with_count.each do |tag|
      tag.name.downcase.three_letter_sections.each do |section|
        key = "autocomplete_tag_#{type.downcase}_#{section}"
        # score is the number of uses of the tag on public works
        score = tag.count
        $redis.zadd(key, score, tag.name)
      end
    end
  end
  
  # load up pseuds
  Pseud.each do |pseud|
    pseud.name.three_letter_sections.each do |section|
      key = "autocomplete_pseud_#{section}"
      # score is the alphabetical value padded out with spaces to max length
      score = pseud.name.downcase.ljust(Pseud::NAME_LENGTH_MAX).b(62).to_i
      $redis.zadd(key, score, pseud.name)
    end
  end
  
  # load up owned tagsets
  # OwnedTagSet.each do |tag_set|
  #   key = "autocomplete_tagset_#{tag_set.id}"
  #   tag_set.tags.each do |tag|
  #     $redis.sadd(key, tag.name)
  #   end
  # end

end
    