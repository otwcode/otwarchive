namespace :skins do
  def user_skin_path
    File.join(Skin.site_skins_dir, "user_skins_to_load")
  end

  def user_skin_preview_path
    File.join(user_skin_path, "previews")
  end

  def parent_skin_path
    File.join(user_skin_path, "parent_only")
  end

  def default_user_skin_preview
    File.join(user_skin_preview_path, "default_preview.png")
  end

  def ask(message)
    print message
    $stdin.gets.chomp.strip
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
        parent_skin = Skin.where(title: parent_name).first
      end
      unless parent_skin
        puts "Couldn't find parent #{parent_name} to add, skipping"
        next
      end
      if (parent_skin.role == "site" || parent_skin.role == "override") && skin.role != "override"
        skin.role = "override"

        unless skin.save
          puts "Problem updating skin #{skin.title} to be replacement skin: #{skin.errors.full_messages.join(', ')}"
          next
        end
      end

      p = skin.skin_parents.build(:parent_skin => parent_skin, :position => parent_position)
      if p.save
        parent_position += 1
      else
        puts "Skipping skin parent #{parent_name}: #{p.errors.full_messages.join(', ')}"
      end
    end
  end

  def load_parent_user_skins(replace:)
    Skin.skin_dir_entries(parent_skin_path, /^.*\.css/).each do |skin_file|
      load_user_css(
        filename: File.join(parent_skin_path, skin_file),
        replace: replace,
        parent_only: true
      )
    end
  end

  desc "Purge user skins parents"
  task(purge_user_skins_parents: :environment) do
    Skin.skin_dir_entries(user_skin_path, /^.*\.css/).each do |skin_file|
      filename = File.join(user_skin_path, skin_file)
      skin_content = File.read(filename)

      unless skin_content.match(%r{SKIN:\s*(.*)\s*\*/})
        puts "No skin title found for skin #{skin_content}"
        next
      end

      skin = Skin.find_by(title: $1.strip)
      skin&.skin_parents&.delete_all
    end
  end

  desc "Load user skins"
  task(load_user_skins: :environment) do
    replace = ask("Replace existing skins with same titles? (y/n) ") == "y"

    Rake::Task["skins:purge_user_skins_parents"].invoke if replace
    load_parent_user_skins(replace: replace)

    Skin.skin_dir_entries(user_skin_path, /^.*\.css/).each do |skin_file|
      load_user_css(
        filename: File.join(user_skin_path, skin_file),
        replace: replace,
        preview_path: File.join(user_skin_preview_path, "#{skin_file}_preview.png")
      )
    end

    # Create Basic Formatting as an official work skin
    WorkSkin.basic_formatting
  end

  def load_user_css(filename:, replace: false, parent_only: false, preview_path: default_user_skin_preview)
    skin_content = File.read(filename)
    return if skin_content.blank?

    unless skin_content.match(%r{SKIN:\s*(.*)\s*\*/})
      puts "No skin title found for skin #{skin_content}"
      return
    end
    title = $1.strip

    skin = Skin.find_by(title: title)
    if skin && !replace
      puts "Existing skin with title #{title} - did you mean to replace? Skipping."
      return
    end
    skin ||= Skin.new

    unless File.exist?(preview_path)
      puts "No preview filename #{preview_path} found for #{title}"
      preview_path = default_user_skin_preview
    end

    if skin_content.match(/MEDIA: (.*?) ENDMEDIA/)
      skin.media = $1.split(/,\s?/)
    elsif skin_content.match(/MEDIA: (\w+)/)
      skin.media = [$1]
    end

    skin.title ||= title
    skin.author ||= User.find_by(login: "lim")
    skin.description = "<pre>#{$1}</pre>" if skin_content.match(%r{DESCRIPTION:\s*(.*?)\*/}m)
    skin.filename = filename
    skin.css = nil # get_css should load from filename
    skin.public = true
    skin.role = "user"
    skin.unusable = parent_only
    skin.official = true
    skin.in_chooser = true unless parent_only
    skin.icon.attach(io: File.open(preview_path, "rb"), content_type: "image/png", filename: "preview.png")
    if skin.save
      puts "Saved skin #{skin.title}"

      skin.cache! if skin.cached?
      if skin_content.match(%r{PARENTS:\s*(.*)\s*\*/})
        parent_string = $1
        set_parents(skin, parent_string)
      end
    else
      puts "Problem with skin #{skin.title}: #{skin.errors.full_messages.join(', ')}"
    end
  end

  desc "Load site skins"
  task(:load_site_skins => :environment) do
    settings = AdminSetting.first
    if settings.default_skin_id.nil?
      settings.default_skin_id = Skin.default.id
      settings.save(validate: false)
    end
    Skin.load_site_css
    Skin.set_default_to_current_version
  end

  desc "Cache all site skins in the skin chooser"
  task(cache_chooser_skins: :environment) do
    # The default skin can be changed to something other than Skin.default via
    # admin settings, so we want to cache that skin, not Skin.default.
    skins = Skin.where(id: AdminSetting.default_skin_id).or(Skin.in_chooser)
    successes = []
    failures = []

    skins.each do |skin|
      if skin.cache!
        successes << skin.title
      else
        failures << skin.title
      end
    end
    puts
    puts("Cached #{successes.join(',')}") if successes.any?
    puts("Couldn't cache #{failures.join(',')}") if failures.any?
    STDOUT.flush
  end

  desc "Remove all existing skins from preferences"
  task(:disable_all => :environment) do
    default_id = AdminSetting.default_skin_id
    Preference.update_all(:skin_id => default_id)
  end

  desc "Unapprove all existing official skins"
  task(:unapprove_all => :environment) do
    default_id = AdminSetting.default_skin_id
    Skin.where("id != ?", default_id).update_all(:official => false)
  end
end
