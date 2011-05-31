module AutocompleteSource
  AUTOCOMPLETE_DELIMITER = ": "
  AUTOCOMPLETE_COMPLETION_KEY = "completion"
  AUTOCOMPLETE_SCORE_KEY = "score"
  AUTOCOMPLETE_RANGE_LENGTH = 50 # not random
  AUTOCOMPLETE_BOOST = 1000 # amt by which we boost results that have all the words
  
  # this marks a completed word in the completion set -- we use double commas because
  # commas are not allowed in pseud and tag names, and double-commas have been disallowed
  # from collection titles
  AUTOCOMPLETE_WORD_TERMINATOR = ",,"

  # override to define any autocomplete prefix spaces where this object should live
  def autocomplete_prefixes
    ["autocomplete_#{self.class.name.downcase}"]
  end
    
  def autocomplete_search_string
    "#{name}"
  end
  
  def autocomplete_value
    "#{id}#{AUTOCOMPLETE_DELIMITER}#{name}" + (self.respond_to?(:title) ? "#{AUTOCOMPLETE_DELIMITER}#{title}" : "")
  end
  
  def autocomplete_score
    0
  end
  
  def add_to_autocomplete(score = nil)
    score = autocomplete_score unless score
    self.class.autocomplete_pieces(autocomplete_search_string).each do |word_piece|
      # each prefix represents an autocompletion space -- eg, "autocomplete_collection_all"
      autocomplete_prefixes.each do |prefix|

        # We put each prefix and the word + completion token into the set of all completions, 
        # with score 0 so they just get sorted lexicographically -- 
        # this will be used to quickly find all possible completions in this space
        $redis.zadd(self.class.autocomplete_completion_key(prefix), 0, word_piece)
        
        # We put each complete search string into a separate set indexed by word with specified score
        if (self.class.is_complete_word?(word_piece))
          $redis.zadd(self.class.autocomplete_score_key(prefix, word_piece), score, autocomplete_value)
        end
      end
    end
  end
  
  def remove_from_autocomplete
    self.class.autocomplete_pieces(autocomplete_search_string).each do |word_piece|
      autocomplete_prefixes.each do |prefix|
        $redis.zrem(self.class.autocomplete_completion_key(prefix), word_piece)
        if (self.class.is_complete_word?(word_piece))
          $redis.zrem(self.class.autocomplete_score_key(prefix, word_piece), autocomplete_value)
        end
      end
    end
  end
  
  module ClassMethods
    def parse_autocomplete_value(current_autocomplete_value)
      current_autocomplete_value.split(AUTOCOMPLETE_DELIMITER, 3)
    end
  
    def fullname_from_autocomplete(current_autocomplete_value)
      current_autocomplete_value.split(AUTOCOMPLETE_DELIMITER, 2)[1]
    end
  
    def id_from_autocomplete(current_autocomplete_value)
      parse_autocomplete_value(current_autocomplete_value)[0]
    end
  
    def name_from_autocomplete(current_autocomplete_value)
      parse_autocomplete_value(current_autocomplete_value)[1]
    end
  
    def title_from_autocomplete(current_autocomplete_value)
      parse_autocomplete_value(current_autocomplete_value)[2]
    end
  
    def autocomplete_lookup(search_param, autocomplete_prefix, options = {:sort => "down"})
      completions = []
      
      # we assume that if the user is typing in a phrase, any words they have
      # entered are the exact word they want, so we only get the prefixes for
      # the very last word they have entered so far
      word_pieces = autocomplete_phrase_split(search_param).map {|w| w + AUTOCOMPLETE_WORD_TERMINATOR}
      word_pieces.last.gsub!(/#{Tag::AUTOCOMPLETE_WORD_TERMINATOR}$/, '')
      
      # get all the complete words that could be part of the user's desired result
      word_pieces.each do |word_piece|
        completions += autocomplete_word_completions(word_piece, autocomplete_prefix)
      end
      completions.uniq!
      
      # for each complete word, we look up the phrases in that word's set
      # along with their scores and add up the scores
      scored_results = {}
      count = {}
      completions.each do |word|        
        phrases_with_scores = $redis.zrevrangebyscore(autocomplete_score_key(autocomplete_prefix, word), 'inf', 0, :withscores)
        while phrases_with_scores.length > 0 do 
          phrase = phrases_with_scores.shift
          score = phrases_with_scores.shift
          
          if options[:constraint_sets]
            # phrases must be in these sets or else no go
            next unless options[:constraint_sets].all {|set| $redis.zrank(set, phrase)}
          end
          if scored_results[phrase]
            scored_results[phrase] += score.to_i
            count[phrase] += 1
          else
            scored_results[phrase] = score.to_i
            count[phrase] = 1
          end
        end
      end

      keys = scored_results.keys.sort do |k1, k2| 
        count[k1] > count[k2] ? -1 : (count[k2] > count[k1] ? 1 :
          scored_results[options[:sort] == "down" ? k2 : k1].to_i <=> scored_results[options[:sort] == "down" ? k1 : k2].to_i)
      end
      limit = options[:limit] || 15
      keys[0..limit]
    end
    
    def is_complete_word?(word_piece)
      word_piece.match(/#{AUTOCOMPLETE_WORD_TERMINATOR}$/)
    end
    
    def get_word(word_piece)
      word_piece.gsub(/#{AUTOCOMPLETE_WORD_TERMINATOR}$/, '')
    end
    
    def autocomplete_score_key(autocomplete_prefix, word)
      autocomplete_prefix + "_" + AUTOCOMPLETE_SCORE_KEY + "_" + get_word(word)
    end
    
    def autocomplete_completion_key(autocomplete_prefix)
      autocomplete_prefix + "_" + AUTOCOMPLETE_COMPLETION_KEY
    end
      
    def autocomplete_phrase_split(string)
        # split into words
        string.downcase.split(/\b/).
          reject {|s| s.blank?}. # get rid of spaces between words 
          reject {|s| s.length == 1 && s.match(/^[[:punct:]]$/)} # get rid of single-character punctuation

        # if we start with a nonword prefix (eg +Anima) add on the first word part for indexing 
        # if string.match /^([^[[:word:]]]+)([^\s]+)/
        #   words << $2.downcase
        # end
    end
    
    def autocomplete_pieces(string)
      # prefixes for autocomplete 
      prefixes = []

      words = autocomplete_phrase_split(string)

      words.each do |word|
        prefixes << word + AUTOCOMPLETE_WORD_TERMINATOR
        word.length.downto(1).each do |last_index|
          prefixes << word.slice(0, last_index)
        end
      end

      prefixes
    end
      
    def autocomplete_word_completions(word_piece, autocomplete_prefix)
      get_exact = is_complete_word?(word_piece)

      # the rank of the word piece tells us where to start looking 
      # in the completion set for possible completions
      start_position = $redis.zrank(autocomplete_completion_key(autocomplete_prefix), word_piece)
      return [] unless start_position
      
      results = []
      # start from that position and go for the specified range length
      $redis.zrange(autocomplete_completion_key(autocomplete_prefix), start_position, start_position + AUTOCOMPLETE_RANGE_LENGTH - 1).each do |entry|
        minlen = [entry.length, word_piece.length].min
        # if the entry stops matching the prefix then we've passed out of
        # the completions that could belong to this word -- return
        return results if entry.slice(0, minlen) != word_piece.slice(0, minlen)
      
        # otherwise if we've hit a complete word add it to the results
        if is_complete_word?(entry)
          results << entry
          return results if get_exact
        end
      end
      
      results
    end
                
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
end