namespace :skins do
  desc "Load site skins"
  task(:load_site_skins => :environment) do
    Skin.load_site_css
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
    skin.skin_parents.delete_all

    parent_position = 1
    parents = parent_names.split(/,\s?/)
    parents.each do |parent_name|
      if parent_name.match(/^(\d+)$/)
        parent_skin = Skin.where("title LIKE 'Archive 2.0: (#{parent_name})%'").first
      else
        parent_skin = Skin.where(:title => parent_name).first
      end
      unless parent_skin
        puts "Couldn't find parent #{parent_name} to add, skipping"
        next
      end
      p = skin.skin_parents.build(:parent_skin => parent_skin, :position => parent_position)
      p.save or puts "Couldn't save skin parent #{parent_name}, skipping"
      parent_position += 1
    end    
  end
  
  desc "Load user skins"
  task(:load_user_skins => :environment) do
    dir = Skin.site_skins_dir + 'user_skins_to_load'
    default_preview_filename = "#{dir}/default_preview.png"
    user_skin_files = Dir.entries(dir).select {|f| f.match(/css$/)}
    skins = []
    user_skin_files.each do |skin_file|
      skins << File.read("#{dir}/#{skin_file}").split(/\/\*\s*END SKIN\s*\*\//)
    end
    skins.flatten!
    
    skins.each do |skin_content|
      next if skin_content.blank?

      # Determine if we're replacing or creating new
      next unless (skin = replace_or_new(skin_content))

      # set the title and preview
      if skin_content.match(/SKIN: ([a-zA-Z0-9\_\-\s]+)$/)
        skin.title = $1
        preview_filename = "#{dir}/#{$1.downcase.gsub(/\s+/, '_')}.png"
        preview = File.exists?(preview_filename) ? preview_filename : default_preview_filename
        File.open(preview, 'rb') {|preview_file| skin.icon = preview_file}
      end

      # set the css and make public
      skin.css = skin_content
      skin.public = true
      skin.official = true
      skin.do_not_upgrade = false

      # make sure we have valid skin now
      unless skin.valid?
        puts "Problem with skin: #{skin.errors.join(', ')}"
        next
      end
      
      skin.save
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
  
end