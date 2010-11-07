namespace :yuletide do

  desc "Load nominated fandoms"
  task(:load_nominated_fandoms => :environment) do
    @nominated_fandoms = File.read("#{Rails.root}/tmp/yuletide_nominated_fandoms_array.txt", :encoding => 'UTF-8').split(/\n/)
  end
  
  desc "Load eligible fandoms"
  task(:load_eligible_fandoms => :environment) do
    @eligible_fandoms = File.read("#{Rails.root}/tmp/yuletide_eligible_fandoms.txt", :encoding => 'UTF-8').split(/\n/)
  end

  desc "Print ineligible fandoms"
  task(:find_ineligible_fandoms => [:load_converted_fandoms, :load_eligible_fandoms]) do
    @ineligible_fandoms = []
    @converted_fandoms.each_key do |original|
      converted, media = @converted_fandoms[original]
      unless @eligible_fandoms.include?(converted)
        @ineligible_fandoms << converted
      end
    end
    puts "INELIGIBLE (OR NOT YET CREATED): "
    @ineligible_fandoms.sort.each {|f| puts f}
  end
  
  desc "Find missing nominated fandoms"
  task(:find_missing_fandoms => :load_converted_fandoms) do
    charlist = File.read("#{Rails.root}/tmp/yuletide_nominated_characters_for_wrangling.txt", :encoding => 'UTF-8')
    fandomlists = charlist.split(/\n\n/)
    @nominated_fandoms = fandomlists.map {|fl| fl.split(/\n/)[0].gsub(/^\[/,'').gsub(/\]$/,'').split(/\s*=>\s*/)[0]} 
    @missing_fandoms = @converted_fandoms.keys.select {|fandom| !@nominated_fandoms.include?(fandom.to_s)}
    puts "MISSING: " + @missing_fandoms.join("\n")
  end

  desc "Load nominated characters"
  task(:load_nominated_characters => :environment) do 
    charlist = File.read("#{Rails.root}/tmp/yuletide_charlist_updated.txt", :encoding => 'UTF-8')
    fandoms = charlist.split(/\n\n/)
    @fandom_characters = {}
    fandoms.each do |fandom|
      fandom_name = fandom.split(/\n/, 2)[0].gsub(/^\[/,'').gsub(/\]$/,'')
      fandom_chars = fandom.split(/\n/, 2)[1] || []
      puts "NO CHARS FOR #{fandom_name}" if fandom_chars.empty?
      @fandom_characters[fandom_name] = fandom_chars.split(/\n/)
    end
    # fandoms.each {|f| @fandom_characters[f.split(/\n/, 2)[0].gsub(/^\[/,'').gsub(/\]$/,'').to_sym] = f.split(/\n/, 2)[1].split(/\n/) }
    # @fandom_characters.delete_if {|key, value| !@nominated_fandoms.include?(key.to_s)}
  end
  
  desc "Load converted fandoms from file"
  task(:load_converted_fandoms => :environment) do
    @converted_fandoms = {}
    File.read("#{Rails.root}/tmp/yuletide_nominated_fandoms_wrangled_utf8.txt", :encoding => 'UTF-8').split(/\r?\n/).each do |fandom|
      #fandom.encode!("UTF-8")
      original, converted, media = fandom.split(/\s*=>\s*/)
      @converted_fandoms[original] = [converted, media]
    end
  end
  
  desc "Load converted characters from file"
  task(:load_converted_characters => :load_converted_fandoms) do
    @converted_chars = {}
    File.read("#{Rails.root}/tmp/yuletide_nominated_characters_wrangled.txt", :encoding => 'UTF-16LE:UTF-8').split(/\r?\n/).each do |line|
      line.encode!("UTF-8")
      if line.match(/^\[(.*)\]/)
        @nominated_fandom, @converted_fandom = $1.split(/\s*=>\s*/)
        @converted_chars[@nominated_fandom] ||= {}
        next
      else
        nominated_char, canonical_char, junk = line.split(/\s*=>\s*/)
        @converted_chars[@nominated_fandom][nominated_char] = canonical_char.blank? ? nominated_char : canonical_char
      end
    end
  end
      
  desc "Create tags for converted fandoms and characters"
  task(:convert_nominations => :load_converted_fandoms) do
    @converted_fandoms.each_key do |original|
      converted, media = @converted_fandoms[original]
      fandom_tag = Fandom.find_by_name(converted)
      if fandom_tag && fandom_tag.canonical
        puts "Canonical tag #{fandom_tag.name} exists for #{original}."
      elsif fandom_tag
        # ugh, not canonical
        puts "Making existing tag #{fandom_tag.name} for #{original} canonical."
        # fandom_tag.canonical = true
        # fandom_tag.save!
      elsif !converted.blank? && !media.blank?
        puts "Creating tag #{converted} for #{original} in media #{media}."        
        #fandom_tag = Fandom.find_or_create_by_name_and_canonical(converted, true)
        #media_tag = Media.find_by_name_and_canonical(media, true)
        #fandom_tag.add_association media_tag if fandom_tag && media_tag
        #fandom_tag.save
      else
        puts "MISSING: tagname or media for #{original}: #{converted}, #{media}"
        next
      end
      
      # now we have fandom_tag
      @converted_chars[original].each_pair do |original_char, converted_char|
        char_tag = Character.find_by_name(converted_char)
        if char_tag && char_tag.canonical
          puts "Canonical tag #{char_tag.name} exists for #{original_char} in #{original}"
        elsif char_tag
          puts "Making existing #{char_tag.name} for #{original_char} in #{original} canonical"
          #char_tag.canonical = true
        else
          puts "Creating tag #{converted_char} for #{original_char} in #{original}"
          #char_tag = Character.find_or_create_by_name_and_canonical(converted_char, true)
        end
        puts "Wrangling tag #{char_tag.name} into #{fandom_tag.name}" if char_tag && fandom_tag
        # char_tag.add_association fandom_tag if char_tag && fandom_tag
        # char_tag.save
      end
    end
  end
  
  desc "Find nominated characters" 
  task(:find_nominated_characters => [:load_nominated_characters, :load_converted_fandoms]) do
    @potential_char_tags = {}
    @fandom_characters.keys.sort.each do |nominated_fandom|
      converted, media = @converted_fandoms[nominated_fandom.to_s]
      puts "\n[#{nominated_fandom} => #{converted}]"
      @potential_char_tags[nominated_fandom] = {}
      @fandom_characters[nominated_fandom].each do |charline|
        nominated_char, canonical_char, fandom = charline.split(/\s*=>\s*/)
        if !canonical_char.blank?
          puts "#{nominated_char} => #{canonical_char}"
        else 
          search_name = nominated_char.upcase
          # exact match?
          tags = Character.find_by_sql("SELECT tags.* from tags where type='Character' AND UPPER(name) LIKE '#{search_name}'")
          if tags.empty?
            # trash short bits of names (eg "Jr" and middle initials and "III")
            words = search_name.split.select {|w| w.length > 3}
            if words.size >= 2
              search_name = words.join(' % ')
              tags = Character.find_by_sql("SELECT tags.* from tags where type='Character' AND UPPER(name) LIKE '#{search_name}'")
            end
          end
          canonical_tags = tags.map {|t| t.canonical ? t : (t.merger ? t.merger : nil)}.compact
          puts "#{nominated_char} => #{canonical_tags.collect(&:name).join(', ')}"
        end
      end
    end
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

