namespace :yuletide do

  desc "Load nominated fandoms"
  task(:load_nominated_fandoms => :environment) do
    @nominated_fandoms = File.read("#{Rails.root}/tmp/yuletide_nominated_fandoms_array.txt").split(/\n/)
  end

  desc "Load nominated characters"
  task(:load_nominated_characters => :load_nominated_fandoms) do 
    charlist = File.read("#{Rails.root}/tmp/yuletide_charlist.txt")
    fandoms = charlist.split(/\n\n/)
    @fandom_characters = {}
    fandoms.each {|f| @fandom_characters[f.split(/\n/, 2)[0].gsub(/^\[/,'').gsub(/\]$/,'').to_sym] = f.split(/\n/, 2)[1].split(/\n/) }
    @fandom_characters.delete_if {|key, value| !@nominated_fandoms.include?(key.to_s)}
  end

  desc "Find nominated fandoms in database"
  task(:find_nominated_fandoms => :load_nominated_fandoms) do
    @potential_tags = {}
    @unlikely_tags = {}
    @no_tags = []
    
    @nominated_fandoms.each do |nominated_fandom|
      puts "Looking for #{nominated_fandom}" 
      @potential_tags[nominated_fandom] = []
      @unlikely_tags[nominated_fandom] = []

      search_name = nominated_fandom.upcase
      
      # let's just look for an exact match
      @potential_tags[nominated_fandom] = Fandom.find_by_sql("SELECT tags.* from tags where type='Fandom' AND canonical='1' AND UPPER(name) LIKE '#{search_name}'")

      if @potential_tags[nominated_fandom].empty? && search_name =~ / AKA /
        # turn "aka" into two names
        search_name = "#{search_name.split(/ AKA /)[0]} #{search_name.split(/ AKA /)[1]}"
        @potential_tags[nominated_fandom] = Fandom.find_by_sql("SELECT tags.* from tags where type='Fandom' AND canonical='1' 
                                                                AND (UPPER(name) LIKE '#{search_name.split(/ AKA /)[0]}' 
                                                                OR UPPER(name) LIKE '#{search_name.split(/ AKA /)[1]}')")

        # if that doesn't work just take the first one                                                        
        search_name = search_name.split(/ AKA /)[0]
      end

      if @potential_tags[nominated_fandom].empty?
        # chop off the last parenthetical (usually "tv" or "movie")
        search_name.gsub!(/\s*\(.*?\)\s*$/, '')
        
        # whack series/trilogy etc
        search_name.gsub!(/\s*(SERIES|TRILOGY)/, '')
      
        # move RPF/RPS to the end of the name
        if search_name =~ /^RP(F|S)\s*-\s*(.*?)$/
          search_name = $2 + " RPF"
        end        

        if search_name.length < 4
          # yeah, this is not going to work
          @no_tags << nominated_fandom
          next
        end

        @potential_tags[nominated_fandom] = Fandom.find_by_sql("SELECT tags.* from tags where type='Fandom' AND canonical='1' AND UPPER(name) LIKE '#{search_name}'")
      end        

      if @potential_tags[nominated_fandom].empty?
        # look for close match
        @potential_tags[nominated_fandom] = Fandom.find_by_sql("SELECT tags.* from tags where type='Fandom' AND canonical='1' AND UPPER(name) LIKE '%#{search_name}%'")
      end
      
      if @potential_tags[nominated_fandom].empty?
        # look for a book fandom
        if search_name =~ /^(.*?)\s*?-\s*?(.*?)$/
          author = $1
          title = $2

          # whack single letters/initials
          author.strip!
          author.gsub!(/^([A-Z]\.?[^\w])+/, '')
          
          # replace middle initials with sql wildcard
          author.gsub!(/[^\w][A-Z]\.?[^\w]/, '%')
          author.strip!

          # whack series/trilogy and articles
          title.strip!
          title.gsub!(/^(THE|A|AN)\s/, '')
          
          @potential_tags[nominated_fandom] = Fandom.find_by_sql("SELECT tags.* from tags where type='Fandom' AND canonical='1' AND UPPER(name) LIKE '%#{title}%-%#{author}%'")
          if @potential_tags[nominated_fandom].empty?
            if title.length > 4 && author.length > 4
              @unlikely_tags[nominated_fandom] = Fandom.find_by_sql("SELECT tags.* from tags where type='Fandom' AND canonical='1' AND (UPPER(name) LIKE '%#{title}%' OR UPPER(name) LIKE '%#{author}%')")
            end
          end
        end
      end
      
      if @potential_tags[nominated_fandom].empty? && @unlikely_tags[nominated_fandom].empty?
        # still no luck. get all words 3+ letters long out of the name and stuff wildcards between, as long as we have at least 2
        words = search_name.gsub(/(^|\s)(THE|A|AN)\s/, ' ').split.select {|w| w.length >= 3}
        if words.size >= 2
          unlikely_search_name = words.join(' % ')
          @unlikely_tags[nominated_fandom] = Fandom.find_by_sql("SELECT tags.* from tags where type='Fandom' AND canonical='1' AND UPPER(name) LIKE '%#{unlikely_search_name}%'")
        end
      end
      
      if @potential_tags[nominated_fandom].empty? && @unlikely_tags[nominated_fandom].empty?
        @no_tags << nominated_fandom 
      end
    end    
    
    # let's see what we got
    puts "Likely tags: "
    @potential_tags.each_pair {|key, val| puts "#{key} => #{val.collect(&:name).join(', ')}" unless val.empty?}
    
    puts "Unlikely tags: "
    @unlikely_tags.each_pair {|key, val| puts "#{key} => #{val.collect(&:name).join(', ')}" unless val.empty?}

    puts "No tags found for the following: \n#{@no_tags.join("\n")}"
    
  end
  
end

