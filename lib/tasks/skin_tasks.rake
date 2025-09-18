namespace :skins do
  def masters_dir
    Rails.public_path.join("stylesheets/masters/")
  end

  def top_level_skins
    dir = File.join(masters_dir, "top_level")
    Dir["#{dir}/*/*.css"]
  end

  def skin_previews_path
    File.join(masters_dir, "previews")
  end

  def parent_only_skins
    dir = File.join(masters_dir, "parent_only")
    Dir["#{dir}/*/*.css"]
  end

  def default_skin_preview_path
    File.join(skin_previews_path, "default_preview.png")
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
    parent_only_skins.each do |skin_file|
      load_user_css(
        filename: skin_file,
        replace: replace,
        parent_only: true
      )
    end
  end

  desc "Purge user skins parents"
  task(purge_user_skins_parents: :environment) do
    top_level_skins.each do |skin_file|
      skin_content = File.read(skin_file)

      unless skin_content.match(%r{SKIN:\s*(.*)\s*\*/})
        puts "No skin title found for skin #{skin_content}"
        next
      end

      skin = Skin.find_by(title: Regexp.last_match(1).strip)
      skin&.skin_parents&.delete_all
    end
  end

  desc "Load user skins"
  task(load_user_skins: :environment) do
    replace = ask("Replace existing skins with same titles? (y/n) ") == "y"

    Rake::Task["skins:purge_user_skins_parents"].invoke if replace
    load_parent_user_skins(replace: replace)

    top_level_skins.each do |skin_file|
      load_user_css(
        filename: skin_file,
        replace: replace,
        preview_path: File.join(File.dirname(skin_file), "preview.png")
      )
    end

    # Create Basic Formatting as an official work skin
    WorkSkin.basic_formatting
  end

  def load_user_css(filename:, replace: false, parent_only: false, preview_path: default_skin_preview_path)
    skin_content = File.read(filename)
    return if skin_content.blank?

    unless skin_content.match(%r{SKIN:\s*(.*)\s*\*/})
      puts "No skin title found for skin #{skin_content}"
      return
    end
    title = Regexp.last_match(1).strip

    skin = Skin.find_by(title: title)
    if skin && !replace
      puts "Existing skin with title #{title} - did you mean to replace? Skipping."
      return
    end
    skin ||= Skin.new

    unless File.exist?(preview_path)
      puts "No preview filename #{preview_path} found for #{title}"
      preview_path = default_skin_preview_path
    end

    case skin_content
    when /MEDIA: (.*?) ENDMEDIA/
      skin.media = Regexp.last_match(1).split(/,\s?/)
    when /MEDIA: (\w+)/
      skin.media = [Regexp.last_match(1)]
    end

    skin.title ||= title
    skin.author ||= User.find_by(login: "lim")
    skin.description = "<pre>#{Regexp.last_match(1)}</pre>" if skin_content.match(%r{DESCRIPTION:\s*(.*?)\*/}m)
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
        parent_string = Regexp.last_match(1)
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
