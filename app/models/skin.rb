require 'fileutils'
include HtmlCleaner
include CssCleaner

class Skin < ActiveRecord::Base
  
  TYPE_OPTIONS = [
                   [ts("Site Skin"), "Skin"],
                   [ts("Work Skin"), "WorkSkin"],
                 ]
    
  # any media types that are not a single alphanumeric word have to be specially handled in get_media_for_filename/parse_media_from_filename
  MEDIA = %w(all screen handheld speech print braille embossed projection tty tv) + ['only screen and (max-width: 480px)']
  IE_CONDITIONS = %w(IE IE5 IE6 IE7 IE8 IE9 IE8_or_lower)
  ROLES = %w(user override)
  ROLE_NAMES = {"user" => "add on to archive skin", "override" => "replace archive skin entirely"}
  # We don't show some roles to users
  ALL_ROLES = ROLES + %w(admin translator site)
  DEFAULT_ROLE = "user"
  DEFAULT_ROLES_TO_INCLUDE = %w(user override site)
  DEFAULT_MEDIA = ["all"]
  
  SKIN_PATH = '/stylesheets/skins/'
  SITE_SKIN_PATH = '/stylesheets/site/'
  
  belongs_to :author, :class_name => 'User'
  has_many :preferences
  
  serialize :media, Array

  # a skin can be both parent and child
  has_many :skin_parents, :foreign_key => 'child_skin_id', 
                          :class_name => 'SkinParent',
                          :dependent => :destroy, :inverse_of => :child_skin
  has_many :parent_skins, :through => :skin_parents, :order => "skin_parents.position ASC", :inverse_of => :child_skins
  
  has_many :skin_children, :foreign_key => 'parent_skin_id',
                                  :class_name => 'SkinParent', :dependent => :destroy, :inverse_of => :parent_skin
  has_many :child_skins, :through => :skin_children, :inverse_of => :parent_skins
                          
  accepts_nested_attributes_for :skin_parents, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:position].blank? }

  has_attached_file :icon,
                    :styles => { :standard => "100x100>" },
                    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
                    :path => %w(staging production).include?(Rails.env) ? ":class/:attachment/:id/:style.:extension" : ":rails_root/public:url",
                    :storage => %w(staging production).include?(Rails.env) ? :s3 : :filesystem,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :bucket => %w(staging production).include?(Rails.env) ? YAML.load_file("#{Rails.root}/config/s3.yml")['bucket'] : "",
                    :default_url => "/images/skins/iconsets/default/icon_skins.png"

  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true
  validates_length_of :icon_alt_text, :allow_blank => true, :maximum => ArchiveConfig.ICON_ALT_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.ICON_ALT_MAX)

  validates_length_of :description, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_length_of :css, :allow_blank => true, :maximum => ArchiveConfig.CONTENT_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)
    
  before_validation :clean_media
  def clean_media
    # handle bizarro cucumber-only error that prevents media from deserializing correctly when attachments are made
    if media && media.is_a?(Array) && !media.empty?
      new_media = media.flatten.compact.collect {|m| m.gsub(/\["(\w+)"\]/, '\1')}
      self.media = new_media
    end
  end
    
  validate :valid_media
  def valid_media
    if media && media.is_a?(Array) && media.any? {|m| !MEDIA.include?(m)}
      errors.add(:base, ts("We don't currently support the media type %{media}, sorry! If we should, please let Support know.", :media => media.join(', ')))
    end
  end

  validates :ie_condition, :inclusion => {:in => IE_CONDITIONS, :allow_nil => true, :allow_blank => true}
  validates :role, :inclusion => {:in => ALL_ROLES, :allow_nil => true, :allow_blank => true}

  validate :valid_public_preview
  def valid_public_preview
    return true if (self.official? || !self.public? || self.icon_file_name)
    errors.add(:base, ts("You need to upload a screencap if you want to share your skin."))
    return false
  end

  attr_protected :official, :rejected, :admin_note, :icon_file_name, :icon_content_type, :icon_size, :description_sanitizer_version, :cached, :featured, :in_chooser

  validates_uniqueness_of :title, :message => ts('must be unique')

  validates_numericality_of :margin, :base_em, :allow_nil => true
  validate :valid_font
  def valid_font
    return if self.font.blank?
    self.font.split(',').each do |subfont|
      if sanitize_css_font(subfont).blank?
        errors.add(:font, "cannot use #{subfont}.")
      end
    end
  end

  validate :valid_colors
  def valid_colors

    if !self.background_color.blank? && sanitize_css_value(self.background_color).blank?
      errors.add(:background_color, "uses a color that is not allowed.")
    end

    if !self.foreground_color.blank? && sanitize_css_value(self.foreground_color).blank?
      errors.add(:foreground_color, "uses a color that is not allowed.")
    end
  end

  validate :clean_css
  def clean_css
    return if self.css.blank?
    self.css = clean_css_code(self.css)
  end

  scope :public_skins, where(:public => true)
  scope :approved_skins, where(:official => true, :public => true)
  scope :unapproved_skins, where(:public => true, :official => false, :rejected => false)
  scope :rejected_skins, where(:public => true, :official => false, :rejected => true)
  scope :site_skins, where(:type => nil)
  
  def self.cached
    where(:cached => true)
  end
  
  def self.in_chooser
    where(:in_chooser => true)
  end
  
  def self.featured
    where(:featured => true)
  end
  
  def self.approved_or_owned_by(user=User.current_user)
    if user.nil?
      where(:public => true, :official => true)
    else
      where("(public = 1 AND official = 1) OR author_id = ?", user.id)
    end
  end
  
  def self.usable
    where(:unusable => false)
  end
  
  def self.sort_by_recent
    order("updated_at DESC")
  end  
  
  def self.sort_by_recent_featured
    order("featured DESC, updated_at DESC")
  end

  def remove_me_from_preferences
    Preference.update_all("skin_id = #{Skin.default.id}", "skin_id = #{self.id}")
  end

  def editable?
    if self.filename.present?
      return false
    elsif self.official && self.public
      return true if User.current_user.is_a? Admin
    elsif self.author == User.current_user
      return true
    else
      return false
    end
  end

  def byline
    if self.author.is_a? User
      author.login
    else
      ArchiveConfig.APP_SHORT_NAME
    end
  end
  

  # create the minimal number of files we can, containing all the css for this entire skin
  def cache!
    self.clear_cache!
    self.public = true
    self.official = true
    save!
    css_to_cache = ""
    last_role = ""
    file_count = 1
    skin_dir = Skin.skins_dir + skin_dirname
    FileUtils.mkdir_p skin_dir
    (get_all_parents + [self]).each do |next_skin|
      if next_skin.get_sheet_role != last_role
        # save to file
        if css_to_cache.present?
          cache_filename = skin_dir + "#{file_count}_#{last_role}.css"
          file_count+=1
          File.open(cache_filename, 'w') {|f| f.write(css_to_cache)}
          css_to_cache = ""
        end
        last_role = next_skin.get_sheet_role
      end
      css_to_cache += next_skin.get_css
    end
    # TODO this repetition is all wrong but my brain is fried
    if css_to_cache.present?
      cache_filename = skin_dir + "#{file_count}_#{last_role}.css"
      File.open(cache_filename, 'w') {|f| f.write(css_to_cache)}
      css_to_cache = ""
    end
    self.cached = true
    save!
  end
  
  def clear_cache!
    skin_dir = Skin.skins_dir + skin_dirname
    FileUtils.rm_rf skin_dir # clear out old if exists    
    self.cached = false
    save!
  end
  
  def get_sheet_role
    "#{get_role}_#{get_media_for_filename}_#{ie_condition}"
  end
  
  # have to handle any media types that aren't a single alphanumeric word here
  def get_media_for_filename
    ((media.nil? || media.empty?) ? DEFAULT_MEDIA : media).map {|m|
      case 
      when m.match(/max-width/)
        "maxwidth"
      else
        m
      end
    }.join('.')
  end
  
  def parse_media_from_filename(media_string)
    media_string.gsub(/maxwidth/, 'only screen and (max-width: 480px)').gsub('.', ', ')
  end
  
  def parse_sheet_role(role_string)
    (sheet_role, sheet_media, sheet_ie_condition) = role_string.split('_')
    sheet_media = parse_media_from_filename(sheet_media)    
    [sheet_role, sheet_media, sheet_ie_condition]
  end
  
  def get_css
    if self.filename
      File.read(Rails.public_path + self.filename)
    else
      self.css
    end
  end
  
  def get_media(separator=", ")
    ((media.nil? || media.empty?) ? DEFAULT_MEDIA : media).join(separator)
  end
  
  def get_role
    self.role || DEFAULT_ROLE
  end
  
  def get_all_parents
    all_parents = []
    parent_skins.each do |parent|
      all_parents += parent.get_all_parents
      all_parents << parent
    end
    all_parents
  end
  
  # This is the main function that actually returns code to be embedded in a page
  def get_style(roles_to_include = DEFAULT_ROLES_TO_INCLUDE)
    style = ""
    if self.get_role != "override" && self.get_role != "site"
      style += AdminSetting.default_skin != Skin.default ? AdminSetting.default_skin.get_style(roles_to_include) : (Skin.get_current_site_skin ? Skin.get_current_site_skin.get_style(roles_to_include) : '')
    end
    style += self.get_style_block(roles_to_include)
    style.html_safe
  end

  def get_ie_comment(style, ie_condition = self.ie_condition)
    if ie_condition.present?
      ie_comment= "<!--[if "
      ie_comment += "lte " if ie_condition.match(/or_lower/)
      ie_comment += "gte " if ie_condition.match(/or_higher/)
      ie_comment += "IE"
      ie_comment += " #{$1}" if ie_condition.match(/IE(\d)/)
      ie_comment += "]>" + style + "<![endif]-->"
    else
      style
    end
  end

  def get_wizard_settings
    style = ""
    if self.margin.present?
      style += "#workskin {margin: auto #{self.margin}%; padding: 0.5em #{self.margin}% 0;}\n"
    end
  
    if self.background_color.present? || self.foreground_color.present? || self.font.present? || self.base_em.present?
      style += "body, #main	{
        #{self.background_color.present? ? "background: #{self.background_color};" : ''}
        #{self.foreground_color.present? ? "color: #{self.foreground_color};" : ''}"
      if self.base_em.present?
        style += "font-size: #{self.base_em}%; line-height:1.125;"
      end
      if self.font.present?
        style += "\nfont-family: #{font};"
      end
      style += "}\n"
    end
    
    if self.paragraph_margin.present?
      style += ".userstuff p {margin-bottom: #{self.paragraph_margin}em;}\n"
    end

    if self.headercolor.present?
      style += "#header .main a, #header .main .current, #header .main input, #header .search input {border-color:transparent;}\n"
      style += "#header, #header ul.main, #footer {background: #{self.headercolor}; border-color: #{self.headercolor}; box-shadow:none;}\n"
    end

    if self.accent_color.present?
      style += "#header .icon, #dashboard ul, #main dl.meta {background: #{self.accent_color}; border-color:#{self.accent_color};}\n"
    end
    
    style
  end
  
  def get_style_block(roles_to_include)
    block = ""
    if self.cached?
      # cached skin in a directory
      block = get_cached_style(roles_to_include)
    else
      # recursively get parents
      parent_skins.each do |parent|
        block += parent.get_style_block(roles_to_include) + "\n"
      end
      
      # finally get this skin
      if roles_to_include.include?(get_role)
        if self.filename.present?
          block += get_ie_comment(stylesheet_link(self.filename, get_media))
        elsif self.css.present?
          block += get_ie_comment('<style type="text/css" media="' + get_media + '">' + self.css + '</style>')
        elsif (wizard_block = get_wizard_settings).present?
          block += '<style type="text/css" media="' + get_media + '">' + wizard_block + '</style>'
        end
      end    
    end
    return block
  end

  def get_cached_style(roles_to_include)
    block = ""
    self_skin_dir = Skin.skins_dir + self.skin_dirname
    Skin.skin_dir_entries(self_skin_dir, /^\d+_(.*)\.css$/).each do |sub_file|
      if sub_file.match(/^\d+_(.*)\.css$/)
        (sheet_role, sheet_media, sheet_ie_condition) = parse_sheet_role($1)
        if roles_to_include.include?(sheet_role)
          block += get_ie_comment(stylesheet_link(SKIN_PATH + self.skin_dirname + sub_file, sheet_media), sheet_ie_condition) + "\n"
        end
      end
    end
    block    
  end
    
  def stylesheet_link(file, media)
    '<link rel="stylesheet" type="text/css" media="' + media + '" href="' + file + '" />'
  end
  
  def self.naturalized(string)
    string.scan(/[^\d]+|[\d]+/).collect { |f| f.match(/\d+(\.\d+)?/) ? f.to_f : f }
  end  

  def self.load_site_css
    Skin.skin_dir_entries(Skin.site_skins_dir, /^\d+\.\d+$/).each do |version|
      version_dir = Skin.site_skins_dir + version + '/'
      if File.directory?(version_dir)
        # let's load up the file
        skins = []
        Skin.skin_dir_entries(version_dir, /^(\d+)-(.*)\.css/).each do |skin_file|
          filename = SITE_SKIN_PATH + version + '/' + skin_file
          skin_file.match(/^(\d+)-(.*)\.css/)
          position = $1.to_i
          title = $2
          title.gsub!(/(\-|\_)/, ' ')
          description = "Version #{version} of the #{title} component (#{position}) of the default archive site design."
          firstline = File.open(version_dir + skin_file, &:readline)
          skin_role = "site"
          if firstline.match(/ROLE: (\w+)/)
            skin_role = $1
          end
          skin_media = ["screen"]
          if firstline.match(/MEDIA: (.*?) ENDMEDIA/)
            skin_media = $1.split(/,\s?/)
          elsif firstline.match(/MEDIA: (\w+)/)
            skin_media = [$1]
          end
          skin_ie = ""
          if firstline.match(/IE_CONDITION: (\w+)/)
            skin_ie = $1
          end
          
          full_title = "Archive #{version}: (#{position}) #{title}"
          skin = Skin.find_by_title(full_title)
          if skin.nil?
            skin = Skin.new
          end
          
          # update the attributes
          skin.title ||= full_title
          skin.filename = filename
          skin.description = description
          skin.public = true
          skin.media = skin_media
          skin.role = skin_role
          skin.ie_condition = skin_ie
          skin.unusable = true
          skin.official = true
          File.open(version_dir + 'preview.png', 'rb') {|preview_file| skin.icon = preview_file}
          skin.save!

          skins << skin
        end
        
        # set up the parent relationship of all the skins in this version
        top_skin = Skin.find_by_title("Archive #{version}")
        if top_skin
          top_skin.clear_cache! if top_skin.cached? 
          top_skin.skin_parents.delete_all
        else
          top_skin = Skin.new(:title => "Archive #{version}", :css => "", :description => "Version #{version} of the default Archive style.", 
                              :public => true, :role => "site", :media => ["screen"])
        end
        File.open(version_dir + 'preview.png', 'rb') {|preview_file| top_skin.icon = preview_file}
        top_skin.official = true
        top_skin.save!
        skins.each_with_index do |skin, index|
          skin_parent = top_skin.skin_parents.build(:child_skin => top_skin, :parent_skin => skin, :position => index+1)
          skin_parent.save!
        end
        if %w(staging production).include? Rails.env
          top_skin.cache!
        end
      end
    end
  end
  
  # get the directory name for the skin file
  def skin_dirname
    "skin_#{self.id}_#{self.title.gsub(/[^\w]/, '_')}/".downcase
  end
    
  def self.skins_dir
    Rails.public_path + SKIN_PATH
  end
  
  def self.skin_dir_entries(dir, regex)
    Dir.entries(dir).select {|f| f.match(regex)}.sort_by {|f| Skin.naturalized(f.to_s)}
  end
  
  def self.site_skins_dir
    Rails.public_path + SITE_SKIN_PATH
  end
  
  # Get the most recent version and find the topmost skin
  def self.get_current_version
    Skin.skin_dir_entries(Skin.site_skins_dir, /^\d+\.\d+$/).last
  end
  
  def self.get_current_site_skin
    current_version = Skin.get_current_version
    if current_version
      Skin.find_by_title_and_official("Archive #{Skin.get_current_version}", true)
    else
      nil
    end
  end    

  def self.default
    Skin.find_by_title_and_official("Default", true) || Skin.create_default
  end

  def self.create_default
    skin = Skin.find_or_create_by_title_and_official(:title => "Default", :css => "", :public => true, :role => "user")
    current_version = Skin.get_current_version
    if current_version
      File.open(Skin.site_skins_dir + current_version + '/preview.png', 'rb') {|preview_file| skin.icon = preview_file}
    else
      File.open(Skin.site_skins_dir + '/preview.png', 'rb') {|preview_file| skin.icon = preview_file}
    end
    skin.official = true
    skin.save!
    skin
  end
  
end
