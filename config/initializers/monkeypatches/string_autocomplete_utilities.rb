class String
  def three_letter_sections
    # split string into all possible lowercase three-letter sections
    three_letter_sections = []
    letters = self.downcase.split(//) 
    while letters.size > 3
      three_letter_sections << letters[0..2].join('')
      letters.shift
    end
    three_letter_sections << letters.join('')
  end
  
  def autocomplete_prefixes(word_end_delimiter = ",")
    # prefixes for autocomplete 
    prefixes = []
    # - split into words
    words = self.downcase.split(/\b/).reject {|s| s.blank? || s.length < 2}
    
    # if we start with a nonword prefix eg +Anima ...What? add on the first word part for indexing 
    if self.match /^([^\w]+)([^\s]+)/
      words << $2.downcase
    end

    words.each do |word|
      prefixes << word + word_end_delimiter
      word.length.downto(1).each do |last_index|
        prefixes << word.slice(0, last_index)
      end
    end
    
    prefixes
  end
  
end
