namespace :skins do

  def ask(message)
    print message
    STDIN.gets.chomp.strip
  end

  def replace_or_new(skin_content)
    skin = Skin.new
    if skin_content.match(/REPLACE:\s*(\d+)/)
      id = $1.to_i
      skin = Skin.where(:id => id).first
      unless skin
        puts "Couldn't find skin with id #{id} to replace"
        return nil
      end
    end
    skin
  end
  
  def set_parents(skin, parent_names)
    # clear existing ones
    SkinParent.where(:child_skin_id => skin.id).delete_all

    parent_position = 1
    parents = parent_names.split(/,\s?/).map {|pn| pn.strip}
    parents.each do |parent_name|
      if parent_name.match(/^(\d+)$/)
        parent_skin = Skin.where("title LIKE 'Archive 2.0: (#{parent_name})%'").first
      elsif parent_name.blank?
        puts "Empty parent name for #{skin.title}"
        next
      else
        parent_skin = Skin.where(:title => parent_name).first
      end
      unless parent_skin
        puts "Couldn't find parent #{parent_name} to add, skipping"
        next
      end
      if (parent_skin.role == "site" || parent_skin.role == "override") && skin.role != "override"
        skin.role = "override"
        skin.save or puts "Problem updating skin #{skin.title} to be replacement skin: #{skin.errors.full_messages.join(', ')}"
        next
      end      
      p = skin.skin_parents.build(:parent_skin => parent_skin, :position => parent_position)
      if p.save
        parent_position += 1
      else
        puts "Skipping skin parent #{parent_name}: #{p.errors.full_messages.join(', ')}"
      end
    end    
  end
  
  def get_user_skins
    dir = Skin.site_skins_dir + 'user_skins_to_load'
    default_preview_filename = "#{dir}/previews/default_preview.png"
    user_skin_files = Dir.entries(dir).select {|f| f.match(/css$/)}
    skins = []
    user_skin_files.each do |skin_file|
      skins << File.read("#{dir}/#{skin_file}").split(/\/\*\s*END SKIN\s*\*\//)
    end
    skins.flatten!
  end
    
  desc "Purge user skins parents"
  task(:purge_user_skins_parents => :environment) do
    get_user_skins.each do |skin_content|
      skin = replace_or_new(skin_content)
      if skin.new_record? && skin_content.match(/SKIN:\s*(.*)\s*\*\//)
        skin = Skin.find_by_title($1.strip)
      end
      skin.skin_parents.delete_all
    end
  end
  
  desc "Load user skins"
  task(:load_user_skins => :environment) do
    replace = ask("Replace existing skins with same titles? (y/n) ") == "y"
    Rake::Task['skins:purge_user_skins_parents'].invoke if replace
    
    author = User.find_by_login("lim")
    dir = Skin.site_skins_dir + 'user_skins_to_load'
    
    skins = get_user_skins
    skins.each do |skin_content|
      next if skin_content.blank?

      # Determine if we're replacing or creating new
      next unless (skin = replace_or_new(skin_content))

      # set the title and preview
      if skin_content.match(/SKIN:\s*(.*)\s*\*\//)
        title = $1.strip 
        if (oldskin = Skin.find_by_title(title)) && oldskin.id != skin.id
          if replace
            skin = oldskin
          else
            puts "Existing skin with title #{title} - did you mean to replace? Skipping."
            next
          end
        end 
        skin.title = title
        preview_filename = "#{dir}/previews/#{title.gsub(/[^\w\s]+/, '')}.png"
        unless File.exists?(preview_filename)
          puts "No preview filename #{preview_filename} found for #{title}"
          preview_filename = "#{dir}/previews/default_preview.png"
        end
        File.open(preview_filename, 'rb') {|preview_file| skin.icon = preview_file}
      else
        puts "No skin title found for skin #{skin_content}"
        next
      end

      # set the css and make public
      skin.css = skin_content
      skin.public = true
      skin.official = true
      skin.author = author unless skin.author
      
      if skin_content.match(/DESCRIPTION:\s*(.*?)\*\//m)
        skin.description = "<pre>#{$1}</pre>"
      end
      if skin_content.match(/PARENT_ONLY/)
        skin.unusable = true
      end

      # make sure we have valid skin now
      if skin.save
        puts "Saved skin #{skin.title}"
      else
        puts "Problem with skin #{skin.title}: #{skin.errors.full_messages.join(', ')}"
        next
      end

      # recache any cached skins
      if skin.cached?
        skin.cache!
      end      
      
      # set parents
      if skin_content.match(/PARENTS:\s*(.*)\s*\*\//)
        parent_string = $1
        set_parents(skin, parent_string)
      end
    end
    
  end

  desc "Load site skins"
  task(:load_site_skins => :environment) do
    Skin.load_site_css
  end

  desc "Cache all site skins"
  task(:cache_all_site_skins => :environment) do
    Skin.where(cached: true).each{|skin| skin.cache!} 
  end
  
  desc "Remove all existing skins from preferences"
  task(:disable_all => :environment) do
    default_id = Skin.default.id
    Preference.update_all(:skin_id => default_id)
  end
  
  desc "Unapprove all existing official skins"
  task(:unapprove_all => :environment) do
    default_id = Skin.default.id
    Skin.where("id != ?", default_id).update_all(:official => false)
  end

  desc "Generate custom CSS so people using an old wizard skin don't lose their skin"
  task(:generate_css_from_old_wizard_settings => :environment) do
    Skin.site_skins.each do |skin|
      old_css = skin.css.present? ? skin.css : ""

      wizard_css = ""

      if skin.margin.present?
        wizard_css += "#workskin {margin: auto #{skin.margin}%; padding: 0.5em #{skin.margin}% 0;} "
      end

      if skin.background_color.present? || skin.foreground_color.present? || skin.font.present? || skin.base_em.present?
        wizard_css += "body, #main { 
          #{skin.background_color.present? ? "background: #{skin.background_color}; " : ''}
          #{skin.foreground_color.present? ? "color: #{skin.foreground_color}; " : ''} "
        if skin.base_em.present?
          wizard_css += "font-size: #{skin.base_em}%; line-height: 1.125; "
        end
        if skin.font.present?
          wizard_css += "font-family: #{skin.font}; "
        end
        wizard_css += "} "
      end

      if skin.paragraph_margin.present?
        wizard_css += ".userstuff p {margin-bottom: #{skin.paragraph_margin}em;} "
      end

      if skin.headercolor.present?
        wizard_css += "#header .main a, #header .main .current, #header .main input, #header .search input {border-color: transparent;} "
        wizard_css += "#header, #header ul.main, #footer {background: #{skin.headercolor}; border-color: #{skin.headercolor}; box-shadow: none;} "
      end

      if skin.accent_color.present?
        wizard_css += "#header .icon, #dashboard ul, #main dl.meta {background: #{skin.accent_color}; border-color:#{skin.accent_color};} "
      end

      wizard_css += "#workskin {margin: auto #{skin.margin}%; padding: 0.5em #{skin.margin}% 0;} " if skin.margin.present?

      # clear out the wizard settings, prepend the wizard css to the user's custom css, and save
      unless wizard_css.blank?
        skin.margin = nil
        skin.background_color = nil
        skin.foreground_color = nil
        skin.font = nil
        skin.base_em = nil
        skin.paragraph_margin = nil
        skin.headercolor = nil
        skin.accent_color = nil
        skin.css = wizard_css + old_css
        skin.save
      end
    end
  end
end
