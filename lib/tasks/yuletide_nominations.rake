# encoding: UTF-8
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

  desc "Load converted fandoms from file"
  task(:old_load_converted_fandoms => :environment) do
    @converted_fandoms = {}
    badchar = "�"
    File.read("#{Rails.root}/tmp/yuletide_nominated_fandoms_wrangled.txt", :encoding => 'UTF-8').split(/\r?\n/).each do |fandom|
      #fandom.encode!("UTF-8")
      fandom.gsub!(badchar, '')
      original, converted, media = fandom.split(/\s*=>\s*/)
      @converted_fandoms[original.strip] = [(converted ? converted.strip : nil), (media ? media.strip : nil)]
    end
  end
  
  desc "Print converted fandoms"
  task(:print_converted_fandoms => :old_load_converted_fandoms) do
    @converted_fandoms.each_pair do |original, conversion|
      converted, media = conversion
      puts "#{original} => #{converted} => #{media}"
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
  
  desc "Load converted characters from file"
  task(:old_load_converted_characters => :old_load_converted_fandoms) do
    @converted_chars = {}
    @seen_fandoms = []
    badchar = "�"
    File.read("#{Rails.root}/tmp/yuletide_nominated_characters_wrangled.txt", :encoding => 'UTF-8').split(/\r?\n/).each do |line|
      #line.encode!("UTF-8")
      line.gsub!(badchar, '')
      if line.blank?
        next
      elsif line.match(/^\[(.*)\]$/)
        @nominated_fandom, @converted_fandom = $1.split(/\s*=>\s*/)
        @nominated_fandom.strip!

        # missing conversion eep
        if @converted_fandom.blank?
          puts "ERROR: no converted name for #{@nominated_fandom}"
        else
          @converted_fandom.strip!
        end
        
        if @seen_fandoms.include?(@nominated_fandom)
          puts "NOTE: already processed #{@nominated_fandom}"
        else
          @seen_fandoms << @nominated_fandom
        end
        @converted_chars[@nominated_fandom] ||= {}
        next
      else
        nominated_char, canonical_char, junk = line.split(/\s*=>\s*/)
        if @nominated_fandom.blank? || nominated_char.blank?
          puts "ERROR: #{@nominated_fandom}, #{nominated_char}"
          next
        end
        @converted_chars[@nominated_fandom][nominated_char] = canonical_char.blank? ? (nominated_char ? nominated_char.strip : nil) : canonical_char.strip
      end
    end
  end

  desc "Create tags for converted fandoms and characters"
  task(:old_convert_nominations => :old_load_converted_characters) do
    @missing = []
    
    # load up the converted fandoms and check if we have an existing canonical tag
    @converted_fandoms.each_key do |original|
      converted, media = @converted_fandoms[original]
      if converted.length > 100
        @missing << "Fandom tag too long: #{converted}"
        next
      end
      
      @fandom_tag = Fandom.find_by_name(converted)
      if @fandom_tag && @fandom_tag.canonical
        puts "Canonical fandom tag #{@fandom_tag.name} exists for #{original}."
      elsif @fandom_tag
        # ugh, not canonical -- synonym?
        if @fandom_tag.merger
          # synonym
          puts "Fandom tag #{@fandom_tag.name} is synonym for #{@fandom_tag.merger.name}, using that instead"
          @fandom_tag = @fandom_tag.merger
        else
          puts "Making existing fandom tag #{@fandom_tag.name} for #{original} canonical."
          @fandom_tag.canonical = true
          @fandom_tag.save!
        end
      elsif !converted.blank? && !media.blank?
        @check_tag = Tag.find_by_name(converted)
        if @check_tag
          @missing << "Requested fandom tag #{converted} already exists and is of type #{@check_tag.type}"
          next
        else
          puts "Creating fandom tag #{converted} for #{original} in media #{media}."        
          @fandom_tag = Fandom.find_or_create_by_name_and_canonical(converted, true)
          media_tag = Media.find_by_name_and_canonical(media, true)
          @fandom_tag.create_filter_count
          @fandom_tag.add_association media_tag if @fandom_tag && media_tag
          @fandom_tag.save!
        end
      else
        @missing << "No tagname or media for #{original}: #{converted}, #{media}"
        next
      end

      # handle deleted fandoms that were wrangled by hand
      if @converted_chars[original].nil?
        @missing << "No characters for fandom #{original}: #{converted}, #{media}"
        next
      end
      
      # now we have @fandom_tag
      @converted_chars[original].each_pair do |original_char, converted_char|
        if converted_char.length > 100
          @missing << "Character tag too long: #{converted_char}"
          next
        end
        
        @char_tag = Character.find_by_name(converted_char)
        if @char_tag && @char_tag.canonical
          puts "\tCanonical char tag #{@char_tag.name} exists for #{original_char}"
        elsif @char_tag
          puts "\tMaking existing char tag #{@char_tag.name} for #{original_char} canonical"
          @char_tag.canonical = true
        else
          @check_tag = Tag.find_by_name(converted_char)
          if @check_tag
            @missing << "Requested character tag #{@check_tag.name} already exists and is of type #{@check_tag.type}"
            next
          else
            puts "\tCreating char tag #{converted_char} for #{original_char}"
            @char_tag = Character.find_or_create_by_name_and_canonical(converted_char, true)
          end
        end
        
        # now we have @char_tag, wrangle it into @fandom_tag
        puts "\tWrangling char tag #{@char_tag.name} into #{@fandom_tag.name}" if @char_tag && @fandom_tag
        @char_tag.add_association @fandom_tag if @char_tag && @fandom_tag
        unless @char_tag.valid?
          @missing << "Problem with character tag #{@char_tag.name} in #{@fandom_tag.name}: #{@char_tag.errors.to_s}"
        else
          @char_tag.save!
        end
      end
    end
    
    puts "MISSING: " 
    puts @missing.join("\n")
  end


  desc "Print eligible character list"
  task(:old_print_eligible_fandom_list => [:old_load_converted_characters, :load_eligible_fandoms]) do
    File.open("#{Rails.root}/tmp/yuletide_charlist_complete.txt", "w+:UTF-8") do |file|
      @converted_fandoms.each_key do |original|
        converted, media = @converted_fandoms[original]
        if @eligible_fandoms.include?(converted)
          fandom_tag = Fandom.find_by_name_and_canonical(converted, true)
          if fandom_tag
            media = fandom_tag.medias.first.name || ""
            file.puts "[#{original} => #{converted} => #{media}]"
            chars = Character.with_parents([fandom_tag]).canonical 
            file.puts chars.map {|char| char.name}.join("\n")
            file.puts ""
          else
            puts "WARNING: fandom #{converted} not found!"
          end
        end
      end
    end
  end


  # Having created the yuletide_charlist_complete file, from here on we want to use that
  # as the source.

  
  desc "Load converted fandoms and characters from complete file"
  task(:load_converted_characters => :environment) do
    @converted_fandoms = {}
    @converted_chars = {}
    File.read("#{Rails.root}/tmp/yuletide_charlist_complete.txt", :encoding => 'UTF-8').split(/\r?\n/).each do |line|
      if line.blank?
        next
      elsif line.match(/^\[(.*)\]$/)
        nominated_fandom, @converted_fandom, media = $1.split(/\s*=>\s*/)
        if @converted_fandom.blank? 
          puts "ERROR: no converted name for #{@nominated_fandom}"
          next
        else 
          @converted_fandom.strip!
        end
        @converted_fandoms[@converted_fandom] = media ? media.strip : nil
        @converted_chars[@converted_fandom] ||= {}
        next
      else
        char = line.strip
        if @converted_fandom.blank? || char.blank?
          puts "ERROR: #{@converted_fandom}, #{char}"
          next
        end
        @converted_chars[@converted_fandom][char] = char
      end
    end
    
    # now get rid of any that were marked
    @converted_chars.keys.each do |fandom|
      @converted_chars[fandom] = @converted_chars[fandom].
          delete_if {|char_key, char| @converted_chars[fandom].has_key?("-#{char}")}
    end 
  end

  desc "Create tags for converted fandoms and characters"
  task(:convert_nominations => :load_converted_characters) do
    @dry_run = true
    @missing = []
    
    puts "DRY RUN" if @dry_run
    
    # load up the converted fandoms and check if we have an existing canonical tag
    @converted_fandoms.each_pair do |fandom, media|
      if fandom.length > 100
        @missing << "Fandom tag too long: #{fandom}"
        next
      end
      
      # create the fandom
      @fandom_tag = Fandom.find_by_name(fandom)
      if @fandom_tag && @fandom_tag.canonical
        puts "Canonical fandom tag #{@fandom_tag.name} exists."
      elsif @fandom_tag
        # ugh, not canonical -- synonym?
        if @fandom_tag.merger
          # synonym
          puts "Fandom tag #{@fandom_tag.name} is synonym for #{@fandom_tag.merger.name}, using that instead"
          @fandom_tag = @fandom_tag.merger
        else
          puts "Making existing fandom tag #{@fandom_tag.name} canonical."
          @fandom_tag.canonical = true unless @dry_run
          @fandom_tag.create_filter_count unless @dry_run
          @fandom_tag.save! unless @dry_run
        end
      elsif fandom.blank? || media.blank?
        @missing << "Tagname or media missing for fandom: #{fandom}, #{media}"
        next
      else
        # let's create the tag
        @check_tag = Tag.find_by_name(fandom)
        if @check_tag
          @missing << "Requested fandom tag #{fandom} already exists and is of type #{@check_tag.type}"
          next
        else
          puts "Creating fandom tag #{fandom} in media #{media}."        
          @fandom_tag = Fandom.find_or_create_by_name_and_canonical(fandom, true) unless @dry_run
          media_tag = Media.find_by_name_and_canonical(media, true)
          @fandom_tag.create_filter_count unless @dry_run
          @fandom_tag.add_association media_tag if @fandom_tag && media_tag && !@dry_run
          @fandom_tag.save! unless @dry_run
        end
      end

      unless @fandom_tag || @dry_run
        @missing << "Tag was not created for #{fandom}!"
        next
      end

      # now we have @fandom_tag
      @converted_chars[fandom].each_key do |char|
        if char.length > 100
          @missing << "Character tag too long: #{char}"
          next
        end
        
        if char.match(/^\-\s*(.*)$/)
          # watch for characters to unwrangle (if they exist)
          @char_tag = Character.find_by_name($1)
          if @char_tag && @fandom_tag
            # get it out of this fandom
            puts "\tUnwrangling #{@char_tag.name} from #{@fandom_tag.name}"
            @char_tag.remove_association(@fandom_tag.id) unless @dry_run
          end
        else
          # check to see if the char tag exists and if not, create it        
          @char_tag = Character.find_by_name(char)
          if @char_tag && @char_tag.canonical
            puts "\tCanonical char tag #{@char_tag.name} exists"
          elsif @char_tag
            if @char_tag.merger
              puts "\tCharacter tag #{@char_tag.name} is synonym for #{@char_tag.merger.name}, using that instead"
              @char_tag = @char_tag.merger
            else
              puts "\tMaking existing char tag #{@char_tag.name} canonical"
              @char_tag.canonical = true unless @dry_run
            end
          elsif char.blank?
            @missing << "Blank character found in #{fandom}."
            next
          else
            # create the character
            @check_tag = Tag.find_by_name(char)
            if @check_tag
              @missing << "Requested character tag #{@check_tag.name} already exists and is of type #{@check_tag.type}"
              next
            else
              puts "\tCreating char tag #{char}"
              @char_tag = Character.find_or_create_by_name_and_canonical(char, true) unless @dry_run
            end
          end
        
          # now we have @char_tag, wrangle it into @fandom_tag
          puts "\tWrangling char tag #{@char_tag.name} into #{@fandom_tag.name}" if @char_tag && @fandom_tag
          @char_tag.add_association @fandom_tag if @char_tag && @fandom_tag && !@dry_run
        end
        
        # make sure we can save
        unless @fandom_tag && @char_tag
          unless @dry_run
            @missing << "Either #{fandom} or #{char} tag was not created."
          end
          next
        end

        unless @char_tag.valid?
          @missing << "Problem with character tag #{@char_tag.name} in #{@fandom_tag.name}: #{@char_tag.errors.to_s}"
        else
          @char_tag.save! unless @dry_run
        end
      end
    end
    
    puts "MISSING: " 
    puts @missing.join("\n")
  end


  desc "Find missing nominated fandoms"
  task(:find_missing_fandoms => [:load_converted_characters, :load_nominated_fandoms]) do
    @missing_fandoms = @nominated_fandoms.select {|fandom| !@converted_fandoms.keys.include?(fandom.to_s)}
    puts "MISSING: " + @missing_fandoms.join("\n")
  end
  
  desc "List fandoms for challenge"
  task(:list_fandoms => :load_converted_characters) do
    puts @converted_chars.keys.collect {|fandom| fandom}.join(", ")
  end

  desc "Print complete character list"
  task(:print_eligible_fandom_list => [:load_converted_characters]) do
    File.open("#{Rails.root}/tmp/yuletide_charlist_complete_new.txt", "w+:UTF-8") do |file|
      @converted_fandoms.keys.sort.each do |fandom|
        fandom_tag = Fandom.find_by_name_and_canonical(fandom, true)
        if fandom_tag
          media = fandom_tag.medias.first.name || ""
          file.puts "[#{fandom} => #{fandom} => #{media}]"
          chars = Character.with_parents([fandom_tag]).canonical 
          file.puts chars.map {|char| char.name}.join("\n")
          file.puts ""
        else
          puts "WARNING: fandom #{fandom} not found!"
        end
      end
    end
  end
  
  desc "Load fandoms into tagset"
  task(:load_fandoms_into_tagset => :load_converted_characters) do
    @challenge = Collection.find_by_name("yuletide2010").challenge
    @converted_fandoms.each_pair do |fandom, media|
      @challenge.offer_restriction.tag_set.tags << Fandom.find_by_name_and_canonical(fandom, true)
    end
    @challenge.offer_restriction.tag_set.save!
    @challenge.save!
  end

end

