
MAX_REPORTED_ERRORS = 1
WORK_CREATOR_VERSION = 'VER 3;;'

class DevmodeController < ApplicationController
  before_filter :development_only
  def development_only
    unless Rails.env == "development"
      flash[:error] = "For development only"
      redirect_to root_path
    end
  end

  def index
    render 
  end

  def unregister_imports
    if params[:okgo]
      for work in Work.all
        if work.imported_from_url
          work.imported_from_url = nil
          work.save false
        end
      end
      flash[:info] = 'Successfully cleared URL associations'
    end
  end

  def profile_logs
    path = ApplicationController.profiler_logging_path
    if params[:logname]
      # If fetching a specific log, just return the html in the log file.
      f = File.new(File.join(path, params[:logname]), 'rb')
      render :text => f.read()
      f.close()
      return
    end
    # If not fetching a log, return a list of log entries.
    paths = []
    raise ["bad dir", path].inspect unless File.exist?(path)
    Dir.new(path).entries.each do |name|
      next unless name.end_with? '.html'
      paths.push File.join(path, name)
    end
    @paths = paths
  end

  # GET list_views
  def list_views
    view_list = []
    view_dir = get_view_dir
    all = []
    view_info = []
    view_dir.entries.each do |name|
      path = File.join(view_dir.path, name)
      # Skip non-files
      next if !File.file? path
      # Skip non-controller files
      next if !name.end_with? '.html.erb'
      view = name[0...name.length-9]
      require path
      view[0] = view[0..0].upcase
      view += 'Controller'
      # Need to CamelCase the name at '_' marks
      name_part_list = view.split('_')
      view = name_part_list.shift
      while !name_part_list.empty?
        name_part = name_part_list.pop
        # First letter upper case
        name_part[0] = name_part[0..0].upcase
        view += name_part
      end
      # camel case done
      begin
        view_obj = eval view
      rescue
        view_info.push [
          view,
          'Could not evaluate'
        ]
      end
      if controller_obj.nil?
        view_info.push [
          view, 
          "Expected #{view} class in #{name}"
        ]
      else
        view_list.push view_obj
      end
    end
    # Process the view files for display.
    raise view_list.inspect
  end

  def get_view_paths(controller, view)
    lst = _get_view_paths(controller, view, stack=[])
    return lst
  end

  def _get_view_paths(controller, view, stack)
    label = "#{controller}/#{view}"
    return [["*** Recurses to #{label}"]] if stack.include? label
    sub_stack = stack + [label]
    # Load the appropriate erb file
    erb_data = load_erb controller, view
    # Scan for ':partial' and '.replace_html'
    partials = []
    erb_data.scan(/<%[=-]?((?:[^%]|%[^>])*?(?:\:partial|\.replace_html)(?:[^%]|%[^>])*)%>/) do |block|
      raise 'unexpected length: ' + block.inspect if block.length != 1
      block[0].scan(/:partial *=> *['"]([a-zA-Z\/_]*)["']/) do |name|
        raise 'unexpected length: ' + name.inspect if name.length != 1
        partials.push name[0]
      end
    end
    # Now take the names of the partial references, and look them up
    link_paths = []
    partials.map do |name|
      l = name.split('/')
      if l.length == 1
        part_controller = controller
        part_view = l[0]
      else
        part_controller = l[0]
        part_view = l[1]
      end
      part_view = '_' + part_view
      link_paths += _get_view_paths(part_controller, part_view, sub_stack)
    end
    # Next, we format these into a list of paths, and return
    return [[label]] + link_paths.map {|path| [label] + path}
  end

  def load_erb(controller, view)
    view_dir = File.join(get_view_dir, controller)
    erb_path = File.join(view_dir, view + '.html.erb')
    raise 'view template not found: ' + controller + '/' + view if !File.exists? erb_path
    erb_file = File.new(erb_path, 'rb')
    data = erb_file.read
    erb_file.close
    return data
  end

  # GET inspect_view
  def inspect_view
    controller = params[:controller_name]
    view = params[:view_name]
    @paths = []
    if controller and view
      # Test controller input format - accept DevmodeController or devmode
      if controller.end_with? 'Controller'
        # It's a class name - change it:
        controller = controller[0...controller.length-10]
        controller = controller.gsub(/[A-Z]/) {|c| '_' + c.downcase}
        controller = controller[1..controller.length]
      end
      # get paths, and display
      paths = get_view_paths(controller, view)
      @paths = paths
    end
  end

  def get_links_to(view)
    if !view.include? '/'
      raise 'Need to know view controller'
    end
    def process_dir(dirname, links, view, stack)
      raise "recurse #{dirname}, #{stack.inspect}" if stack.include? dirname
      raise "stack #{stack.inspect}" if stack.length > 20
      substack = stack + [dirname]
      if File.file? dirname
        filename = dirname
        return if !filename.end_with? ".html.erb"
        process_file filename, links, view
      elsif File.directory? dirname
        dir = Dir.new(dirname)
        dir.entries.each do |name|
          process_dir(File.join(dirname, name), links, view, substack) if name != '.' and name != '..'
        end
      end
    end
    def process_file(filename, links, view)
      search_view = view.gsub('/_', '/')
      main_view_controller, main_view = view.split('/')
      view_file = File.new(filename, 'rb')
      dirname, view_name = File.split(filename)
      view_name = view_name[0...(view_name.length-('.html.erb'.length))]
      view_search_name = view_name
      view_search_name = view_search_name[1..view_search_name.length] if view_search_name.start_with? "_"
      controller = File.split(dirname)[1]
      erb_data = view_file.read
      view_file.close
      if erb_data =~ /'#{search_view}'/ or erb_data =~ /"#{search_view}"/ or
        (main_view_controller == controller and
        (erb_data =~ /'#{view_search_name}'/ or erb_data =~ /"#{view_search_name}"/))
        links.push [controller, view_name]
      end
    end
    links = []
    process_dir get_view_dir, links, view, []
    return links
  end

  def backtrace_view
    @links = []
    view = params[:viewname]
    if view.nil? or view.blank?
      @errors = "No view name provided. Go through devmode menus"
      render and return
    end
    @viewname = view
    @links = get_links_to view
  end

  def get_controller_dir
    return Dir.new(File.dirname(__FILE__))
  end

  def get_view_dir
    return File.join(File.dirname(__FILE__), '..', 'views')
  end

  # GET /devmode/
  def list_controllers
    # This magic global method allows us to inspect every object in memory!
#    controller_names = ActionController::Routing.possible_controllers
    controllers_list = []
    controller_dir = get_controller_dir
    view_dir = get_view_dir
    all = []
    controller_info = []
    controller_dir.entries.each do |name|
      path = File.join(controller_dir.path, name)
      # Skip non-files
      next if !File.file? path
      # Skip non-controller files
      next if !name.end_with? '_controller.rb'
      raise 'nilname' if name.nil?
      controller = name[0...name.length-14]
      # Save this for use in the view path prefix later.
      underscored_path = controller.dup
      raise name if underscored_path.nil?
      # We require the file's contents to be loaded.
      require path
      controller[0] = controller[0..0].upcase
      controller += 'Controller'
      # Need to CamelCase the name at '_' marks
      name_part_list = controller.split('_')
      controller = name_part_list.shift
      while !name_part_list.empty?
        name_part = name_part_list.shift
        # First letter upper case
        name_part[0] = name_part[0..0].upcase
        controller += name_part
      end
      # camel case done
      # This trick will 
      begin
        controller_obj = eval controller
      rescue
        controller_info.push [
          controller,
          'Could not evaluate'
        ]
      end
      if controller_obj.nil?
        controller_info.push [
          controller, 
          "Expected #{controller} class in #{name}"
        ]
      else
        controllers_list.push [controller_obj, underscored_path]
      end
    end
    controllers_list.each do |controller, dirname|
      info = []
      info.push controller.name
      raise controllers_list.inspect if dirname.nil?
      controller_view_dir = File.join(view_dir, dirname)
      controller_view_dir = nil if !File.exists? controller_view_dir
      view_methods = []
      other_methods = []
      controller.instance_methods(false).each do |name|
        if !controller_view_dir.nil? and Dir.new(controller_view_dir).include? "#{name}.html.erb"
          view_methods.push name
        else
          other_methods.push name
        end
      end
      info.push view_methods
      info.push other_methods.inspect
      controller_info.push info
    end
    controller_info.sort!
    @controllers =  controller_info
  end

  # GET+POST /devmode/seedusers
  def seedusers
    if params[:seed]
      # POST
      errors = []

      start = params[:user_start].to_i
      count = params[:user_count].to_i
      end_no = start + count - 1

      user_name = lambda {|i| [params[:user_prefix], i].join("")}

      for i in (start..end_no)
        email = [params[:email_prefix], i, params[:email_suffix]].join("")
        login = user_name.call i

        user = User.new(
          :login => login,
          :email => email,
          :password => params[:password],
          :password_confirmation => params[:password],
          :age_over_13 => "1",
          :terms_of_service => "1"
        )
        if user.save
          # Activation doesn't seem to work in a single save. We now need to 
          # activate, and save again.
          if params[:prevalidate]
            user.activated_at = Time.now
            user.activation_code = nil
            unless user.save
              errors.push [login] + user.errors.full_messages
            end
          end
        else
          errors.push [login] + user.errors.full_messages
        end
      end

      if errors.empty?
        flash[:notice] = "Seeding successful from '#{user_name.call start}' to '#{user_name.call end_no}'"
        redirect_to "/devmode"
      else
        @errors = "Errors: <ul>" + errors.map {|x| "<li>" + x.join("</li><li>") + "</li>"}.join("</ul><br /><ul>") + "</ul>"
        @params = params
        @params.delete "seed"
      end
    end

    # GET default response
    @params = [
      [:prevalidate, [:checkbox, '" checked="checked']],
      [:user_start, [:text, "1"]],
      [:user_count, [:text, "100"]],
      [:user_prefix, [:text, 'testuser']],
      [:password, [:text, "password"]],
      [:email_prefix, [:text, "user"]],
      [:email_suffix, [:text, ".mail@somedomain.com"]],
    ]
  end

  # Assists seedworks
  def create_work(name, authors, ratings, warnings, characters, relationships, fandoms, chapter_count, chapter_char_count)
    raise "Provide fandoms" if fandoms.nil? or fandoms.empty?
    raise "Provide chapter count" if chapter_count.nil?
    raise "Provide chapter char count" if chapter_char_count.nil?
    raise "Provide authors" if authors.nil? or authors.empty?
    raise "Non unique fandoms" if fandoms.uniq.sort != fandoms.sort
    raise "Non unique characters #{characters.map(&:to_str).inspect}" if characters.uniq.sort != characters.sort

    # Provide a function to generate new chapters. Keeps them all different
    new_chapter = lambda {"#{WORK_CREATOR_VERSION} #{random_chapter chapter_char_count}"}

    notes = new_chapter.call[0...500]
    end_notes = new_chapter.call[0...500]
    summary = new_chapter.call[0...1250]

    # Taggings:
    # # rating
    # # warning
    # # fandoms
    # # category
    # # relationships
    # # characters
    # # freeform

    chapters = []
    for c_idx in (1..chapter_count)
      title = new_chapter.call[0...255]
      # title =
      position = c_idx
      content = new_chapter.call[0...500000]
      # Authorship + pseuds
      chapter = Chapter.new(
        :authors => authors,
        :content => content,
        :position => position,
        :title => title,
        :posted => true
      )
      chapter.set_word_count
      chapters.push chapter
    end

    work_params = {
      :collection_ids => [],
      :wip_length => chapter_count,
      :series => [],
      :title => name[0...255],
      :chapters => chapters,
      :authors => authors,
      :summary => summary,
      :fandoms => fandoms,
      :ratings => ratings,
      :characters => characters,
      :relationships => relationships,
      :warnings => warnings,
      :notes => notes,
      :endnotes => end_notes,
#      :parent_url => nil,
      :restricted => false,
      :ratings => ratings,
      :posted => true
    }
    work = Work.new(work_params)
    work.set_word_count
    return work
  end

  def comment_works
    # GET params
    @params = {
      #
    }
    if params[:create]
      # POST
      # do the actual creation
    end
  end

  # Assists seedworks
  def comment_work(work, comments, subcomment_chance, comment_length)
    # not implemented yet
  end

  def random_chapter(characters, fuzziness=50)
    raise "Provide characters count!" if characters.nil?
    paragraphs = []
    count = 0
    while count < characters - fuzziness
      new_paragraph = Faker::Lorem.paragraph(rand(4) + 6)
      count += new_paragraph.length
      paragraphs.push new_paragraph
    end
    return paragraphs.join("<br/>")
  end

  def random_sentence(characters, fuzziness=4)
    words = []
    count = 0
    while count < [characters - fuzziness, 1].max
      new_word = Faker::Lorem.words(1)
      count += new_word.length + 1
      words.push new_word
    end
    return words.join(" ")
  end

  def seedworks
    # GET default response
    max_errors = 1

    # This array is rendered in rows by the view. Each element is either:
    #  * A heading: [:Title, nil]
    #  * An <input>: [:name, [:type, 'default', 'description...']]
    #
    @params = [
      [:Works, nil],
      [:work_count, [:text, "10", "This many works will be added. Don't try more than about 20 over the web."]],
      [:author_prefix, [:text, "author_", "Only users with this name prefix will authors of new works."]],
      [:num_authors_two_weight, [:text, '1', "Weighting on work by 2 authors"]],
      [:num_authors_one_weight, [:text, '30', "Weighting on work by 1 author only"]],

      [:Content, nil],
      [:chapter_count_long_weight, [:text, '1', "Weighting on 11-60 chapters"]],
      [:chapter_count_med_weight, [:text, '2', "Weighting on 2-10 chapters"]],
      [:chapter_count_short_weight, [:text, '30', "Weighting on 1 chapter"]],
      [:chapter_long_weight, [:text, '1', "Weighting on chapter length being over 450000 characters"]],
      [:chapter_med_weight, [:text, '2', "Weighting on chapter length being over 2001-100000 characters"]],
      [:chapter_short_weight, [:text, '10', "Weighting on chapter length being under 2000 characters"]],
      [:work_name_long_weight, [:text, '1', "Weighting on work name length being over 301 characters"]],
      [:work_name_med_weight, [:text, '2', "Weighting on work name length being over 51-300 characters"]],
      [:work_name_short_weight, [:text, '10', "Weighting on work name length being under 50 characters"]],

      [:"Comments - (Not implemented yet)", nil],
      [:comment_only_by_user_prefix, [:text, "", "Only users with this prefix to their login will be adding comments"]],
      [:comment_on_comment_chance, [:text, "0.5", "Probability of a new comment having a further comment added to it."]],
      [:chapter_count_med_weight, [:text, '1', "Weighting on full paragraph comment"]],
      [:chapter_count_short_weight, [:text, '20', "Weighting on one line comment"]],

      [:Fandoms, nil],
      [:in_fandoms, [:text, "", "If not set, random fandoms will be assigned. If set, use a comma separated list, and fandoms will be taken from this list."]],
      [:max_new_fandoms, [:text, '5', 'When creating fandoms is allowed, at most this many new fandoms will be created.']],
      [:fandoms_count_med_weight, [:text, '2', "Weighting on work of 2 fandoms"]],
      [:fandoms_count_short_weight, [:text, '30', "Weighting on work of 1 fandom only"]],

      [:Tags, nil],
      [:max_new_characters, [:text, '5', 'At most this many new characters will be created']],
      [:max_new_relationships, [:text, '5', 'At most this many new relationships will be created']]
    ] unless @params

    if params['seed']
      # POST

      # First, get some data in order before we start creating works.
      errors = []
      new_works = []

      # Verify params
      chapter_count = WeightedRandom.from_params(params, "chapter_count", {
        'long' => (11..60),
        'med' => (2..10),
        'short' => (1..1),
      })
      chapter_length = WeightedRandom.from_params(params, "chapter", {
        'long' => (100001..450000),
        'med' => (2001..100000),
        'short' => (800..2000),
      })
      work_name_length = WeightedRandom.from_params(params, "work_name", {
        'long' => (301..500),
        'med' => (51..300),
        'short' => (1..50),
      })
      fandoms_count = WeightedRandom.from_params(params, "fandoms_count", {
        'long' => 3,
        'med' => 2,
        'short' => 1,
      })
      authors_count = WeightedRandom.from_params(params, "num_authors", {
        'two' => 2,
        'one' => 1,
      })

      if params['work_count']
        work_count = params['work_count'].to_i
      else
        errors = 'Must set work count'
      end
      work_count = params['work_count'].to_i

      # Fandoms.
      fandom_list = []
      if params['in_fandoms']
        params['in_fandoms'].split(",").each do |fandom_name|
          fandom_name.strip!
          if fandom_name
            fandom = Fandom.get_by_name(fandom_name)
            if fandom
              fandom_list.push fandom
            else
              errors.push "Fandom '#{h fandom_name}' not found"
            end 
          end
        end
      end
      if fandom_list.empty?
        all_fandoms = Fandom.all
      end
      all_fandoms += [nil] * params['max_new_fandoms'].to_i
      new_fandom_func = lambda {
        new_name = random_sentence(8 + (rand(4) * rand(4)))
        Fandom.new(
          :name => new_name
        )
      }

      all_categories = []
      all_warnings = Warning.all
      all_ratings = Rating.all
      all_characters = Character.all
      all_characters += [nil] * params['max_new_characters'].to_i
      new_character_func = lambda {
        new_name = random_sentence(4 + rand(12))
         Character.find_or_create_by_name(
          new_name
        )
      }
      all_relationships = Relationship.all
      all_relationships += [nil] * params['max_new_relationships'].to_i
      new_relationship_func = lambda {
        new_name = [random_sentence(4 + rand(12)), random_sentence(4 + rand(12))].join('/')
        Relationship.new(
          :name => new_name
        )
      }

      all_authors = User.all.select{|x| x.login.start_with? params["author_prefix"]}

      if all_authors.nil?
        errors.push "Author selection failed"
      elsif all_authors.empty?
        errors.push "No authors found."
      end

      # All data gathered

      # We'll need to pick or create fandoms, characters, tags, etc, so use a Proc
      pick_or_create = Proc.new do |list, create_func|
        item = list.choice
        if item.nil?
          item = create_func.call
          # Put the new item into the list
          if not list.include? item
            nil_pos = list.index nil
            list[nil_pos..nil_pos] = item
          end
        end
        item
      end

      logger.info("Starting to create #{work_count} works")

      # Now the loop to create works. We just go round, picking/creating random
      # data according to the conditions and data above.
      # There's a condition written at the end of this loop to skip it if
      # we've encountered errors already.
      for work_idx in (1..work_count)
        # Create work
        work_name = lambda do
          len = work_name_length.choice
          random_sentence(len)
        end

        num_fandoms = fandoms_count.choice

        if !fandom_list.empty?
          fandoms = fandom_list
        else
          fandoms = []
          # Randomly choose fandoms
          num_fandoms.times {fandoms.push pick_or_create.call(all_fandoms, new_fandom_func)}
        end

        warnings = [all_warnings.choice]
        ratings = [all_ratings.choice]
        num_characters = 2
        num_relationships = 1

        # parameterise later
        characters = []
        num_characters.times {characters.push pick_or_create.call(all_characters, new_character_func)}
        relationships = []
        num_relationships.times {relationships.push pick_or_create.call(all_relationships, new_relationship_func)}

        # Select some random authors
        authors = []
        num_authors = authors_count.choice
        num_authors.times {authors.push all_authors.choice.pseuds.choice}

        begin
          work = create_work(work_name.call, authors, ratings, warnings, characters, relationships, fandoms, chapter_count.choice, chapter_length.choice)
        rescue Exception => ex
          # I include the backtrace because this is a development server tool.
          errors.push "EXCEPTION OCURRED '#{ex.message}':<br/>#{ex.backtrace}"
        rescue msg
          errors.push msg
        end

        for chapter in work.chapters
          unless chapter.save
            errors.push chapter.errors.full_messages
            break
          end
        end unless work.nil?

        if work.nil?
          errors.push "No work created"
        elsif work.word_count == 0
          errors.push "No words in work"
        elsif work.save
          new_works.push work
        else
          unless new_works.empty?
            errors.push "After #{new_works.length} works"
          end
          errors.push "Save failed: #{work.errors.full_messages}, #{work}; #{characters.collect(&:name)}"
        end
        break if errors.length >= max_errors

        # Add comments to work

      end if errors.empty?

      if errors.empty?
        flash[:notice] = "Seeding successful"
        redirect_to "/devmode"
      else
        logger.warn("Error creating #{work_count} works. #{errors.join '\n'}")
        begin
          @errors = "Errors: <ul>" + errors.map {|x| x ? ("<li>" + x.respond_to?("join")?x.join("</li><li>"):x + "</li>"):''}.join("</ul><br /><ul>") + "</ul>"
        rescue
          @errors = errors.inspect
        end
        # Copy input parameters back to the form defining arrays
        for name in params.keys
          # convert to a symbol for equality tests
          name_sym = name.to_sym
          if entry = @params.detect{|x| x[0] == name_sym}
            entry[1][1] = params[name]
            # A html hack for checkboxes. (I know, but it's a developer tool)
            if entry[1][0] == :checkbox
              entry[1][1] = '" checked="checked'
            end
          end
        end
        @params.delete "seed"
      end
    end
  end
end

class WeightedRandom
  # w = WeightedRandom.new {"x" => 3, "y" => 1}
  #
  def initialize(weights)
    @weights = weights
    total = 0
    weights.each {|option, weight| total += weight}
    @totalweight = total
  end
  def choice
    # Pick a number up to totalweight
    index = rand(@totalweight)
    # Then pick the option by weight
    count = 0; opt = @weights.detect{|option, weight| (count += weight) >= index}[0]
    if opt.is_a? Range
      max = opt.max or 1
      min = opt.min or 1
      choice =  min + rand(max-min + 1)
      raise [choice, min, man].inspect if !choice.between?(opt.min, opt.max)
      return choice
    else
      raise @weights if opt.nil?
      return opt
    end
  end
  def WeightedRandom.from_params(params, name, types)
    weights = {}
    for item in params.keys.select {|x| x.start_with? name and x.end_with? '_weight'}
      weight = params[item].to_i
      type_name = item.slice(0...item.length-7).slice(name.length+1, item.length)
      next if type_name.nil? or type_name.include? '_'
      value = types[type_name]
      raise ["nil type value", type_name, item, name, weight].inspect if value.nil?
      weights[value] = weight
    end
    return WeightedRandom.new weights
  end
end
