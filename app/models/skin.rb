include SanitizeParams

class Skin < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_many :preferences

  HUMANIZED_ATTRIBUTES = {
    :icon_file_name => "Skin preview"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  has_attached_file :icon,
  :styles => { :standard => "100x100>" },
  :url => "/system/:class/:attachment/:id/:style/:basename.:extension", 
  :path => ENV['RAILS_ENV'] == 'production' ? ":class/:attachment/:id/:style.:extension" : ":rails_root/public:url",  
  :storage => ENV['RAILS_ENV'] == 'production' ? :s3 : :filesystem,
  :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
  :bucket => ENV['RAILS_ENV'] == 'production' ? YAML.load_file("#{RAILS_ROOT}/config/s3.yml")['bucket'] : "",
  :default_url => "/images/skin_preview_none.png"
   
  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true 
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true 
  validates_length_of :icon_alt_text, :allow_blank => true, :maximum => ArchiveConfig.ICON_ALT_MAX,
    :too_long => t('icon_alt_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.ICON_ALT_MAX)

  validates_length_of :description, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => t("skin.description_too_long", :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_length_of :css, :allow_blank => true, :maximum => ArchiveConfig.CONTENT_MAX,
    :too_long => t("skin.css_too_long", :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.CONTENT_MAX)

  validates_attachment_presence :icon, :if => :public?, :message => t('skin.preview_not_set', :default => "should be set for the skin to be public: please take a screencap of your skin in action.")
  
  attr_protected :official, :rejected, :admin_note, :icon_file_name, :icon_content_type, :icon_size

  validates_uniqueness_of :title, :message => t('skin_title_already_used', :default => 'must be unique')

  validates_numericality_of :margin, :base_em, :allow_nil => true
  validate :valid_font
  def valid_font
    return if self.font.blank?
    get_white_list_sanitizer
    self.font.split(',').each do |subfont|
      if @white_list_sanitizer.sanitize_css_value(subfont).blank?
        errors.add(:font, "cannot use #{subfont}.")
      end
    end
  end
  
  validate :valid_colors
  def valid_colors
    get_white_list_sanitizer
    
    if !self.background_color.blank? && @white_list_sanitizer.sanitize_css_value(self.background_color).blank?
      errors.add(:background_color, "uses a color that is not allowed.")
    end
      
    if !self.foreground_color.blank? && @white_list_sanitizer.sanitize_css_value(self.foreground_color).blank?
      errors.add(:foreground_color, "uses a color that is not allowed.")
    end
  end
        
  validate :clean_css
  def clean_css
    return if self.css.blank?
    scanner = StringScanner.new(self.css)
    if !scanner.exist?(/\/\*/) 
      # no comments, clean the whole thing
      self.css = clean_css_code(self.css)
    else
      clean_code = []
      while (scanner.exist?(/\/\*/)) 
        clean_code << (clean = clean_css_code(scanner.scan_until(/\/\*/)))
        clean_code << '/*' + scanner.scan_until(/\*\//) if scanner.exist?(/\*\//)
      end
      clean_code << (clean = clean_css_code(scanner.rest))
      self.css = clean_code.delete_if {|code_block| code_block.blank?}.join("\n")
    end
  end
        
protected

  # We parse and clean the CSS line by line in order to provide more helpful error messages.
  def clean_css_code(css_code)
    clean_css = ""
    get_white_list_sanitizer
    parser = CssParser::Parser.new
    parser.add_block!(css_code)
    parser.each_rule_set do |rs|
      clean_rule = "#{rs.selectors.map {|selector| selector.gsub(/\n/, '').strip}.join(",\n")} {\n"
      rs.each_declaration do |property, value, is_important|
        declaration = "#{property}: #{value}#{is_important ? ' !important' : ''};"
        clean_declaration = @white_list_sanitizer.sanitize_css_declaration(declaration)
        # if we differ in anything but case or whitespace, there's an issue
        if declaration.downcase.gsub(/\s+/, '') != clean_declaration.downcase.gsub(/\s+/, '') 
          if clean_declaration.empty?
            if declaration !~ /^(\s*[-\w]+\s*:\s*[^:;]*(;|$)\s*)*$/ 
              errors.add_to_base("The code for #{rs.selectors.join(',')} doesn't seem to be a valid CSS rule.")
            else
              # the property is not allowed
              errors.add_to_base("The declarations for #{rs.selectors.join(',')} cannot use the property <strong>#{property}</strong>")
            end
          else
            errors.add_to_base("The #{property} property in #{rs.selectors.join(',')} cannot have the value <strong>#{value}</strong>")
          end
        else
          clean_rule += "  #{clean_declaration}\n"
        end
      end
      clean_rule += "}\n\n"
      clean_css += "#{clean_rule}"
    end
    return clean_css
  end
  
public

  named_scope :public_skins, :conditions => {:public => true}
  named_scope :approved_skins, :conditions => {:official => true, :public => true}
  named_scope :unapproved_skins, :conditions => {:public => true, :official => false, :rejected => false}
  named_scope :rejected_skins, :conditions => {:public => true, :official => false, :rejected => true}

  def remove_me_from_preferences
    Preference.update_all("skin_id = #{Skin.default.id}", "skin_id = #{self.id}")
  end

  def self.create_default
    skin = Skin.find_or_create_by_title(:title => "Default", :css => "", :public => true)
    File.open(Rails.public_path + '/images/skin_preview_default.png', 'rb') {|preview_file| skin.icon = preview_file} 
    skin.official = true
    skin.save
    skin
  end

  def self.default
    Skin.find_by_title("Default") || Skin.create_default
  end

  def self.import_plain_text
    css = File.read(Rails.public_path + "/stylesheets/plain_text_skin.css")
    skin = Skin.find_or_create_by_title(:title => "Plain Text", :css => css, :public => true)
    File.open(Rails.public_path + '/images/skin_preview_plaintext.png', 'rb') {|preview_file| skin.icon = preview_file} 
    skin.official = true
    skin.save
    skin
  end

  def editable?
    return false if self.official
    return true if self.author == User.current_user
    return false
  end

  def byline
    if self.author.is_a? User
      author.login
    else
      ArchiveConfig.APP_SHORT_NAME
    end
  end

end
