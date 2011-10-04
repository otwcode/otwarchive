include HtmlCleaner
include CssCleaner

# BACK END, instead of this hardcoded default image can we have
# <div class="icon"></div>
# obviously no alt text is necessary in this case
class Skin < ActiveRecord::Base

  TYPE_OPTIONS = [
                   [ts("Site Skin"), "Skin"],
                   [ts("Work Skin"), "WorkSkin"],
                 ]
  
  
  belongs_to :author, :class_name => 'User'
  has_many :preferences

  has_attached_file :icon,
                    :styles => { :standard => "100x100>" },
                    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
                    :path => Rails.env.production? ? ":class/:attachment/:id/:style.:extension" : ":rails_root/public:url",
                    :storage => Rails.env.production? ? :s3 : :filesystem,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :bucket => Rails.env.production? ? YAML.load_file("#{Rails.root}/config/s3.yml")['bucket'] : "",
                    :default_url => "/images/skins/iconsets/default/icon_skins.png"

  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true
  validates_length_of :icon_alt_text, :allow_blank => true, :maximum => ArchiveConfig.ICON_ALT_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.ICON_ALT_MAX)

  validates_length_of :description, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_length_of :css, :allow_blank => true, :maximum => ArchiveConfig.CONTENT_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)

  validate :valid_public_preview
  def valid_public_preview
    return true if (self.official? || !self.public? || self.icon_file_name)
    errors.add(:base, ts("You need to upload a screencap if you want to share your skin."))
    return false
  end

  attr_protected :official, :rejected, :admin_note, :icon_file_name, :icon_content_type, :icon_size, :description_sanitizer_version

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
    scanner = StringScanner.new(self.css)
    if !scanner.exist?(/\/\*/)
      # no comments, clean the whole thing
      self.css = clean_css_code(self.css)
    else
      clean_code = []
      while (scanner.exist?(/\/\*/))
        clean_code << (clean = clean_css_code(scanner.scan_until(/\/\*/).chomp('/*')))
        clean_code << '/*' + scanner.scan_until(/\*\//) if scanner.exist?(/\*\//)
      end
      clean_code << (clean = clean_css_code(scanner.rest))
      self.css = clean_code.delete_if {|code_block| code_block.blank?}.join("\n")
    end
  end

  scope :public_skins, where(:public => true)
  scope :approved_skins, where(:official => true, :public => true)
  scope :unapproved_skins, where(:public => true, :official => false, :rejected => false)
  scope :rejected_skins, where(:public => true, :official => false, :rejected => true)
  scope :site_skins, where(:type => nil)
  scope :approved_or_owned_by, lambda {|user| where("(public = 1 AND official = 1) OR author_id = ?", user.id)}

  def remove_me_from_preferences
    Preference.update_all("skin_id = #{Skin.default.id}", "skin_id = #{self.id}")
  end

  def self.default
    Skin.find_by_title_and_official("Default", true) || Skin.create_default
  end

  def self.plain_text
    Skin.find_by_title_and_official("Plain Text", true) || Skin.import_plain_text
  end

  def editable?
    if self.official && self.public
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

  private

  def self.create_default
    skin = Skin.find_or_create_by_title_and_official(:title => "Default", :css => "", :public => true, :official => true)
    File.open(Rails.public_path + '/images/skins/previews/default.png', 'rb') {|preview_file| skin.icon = preview_file}
    skin.official = true
    skin.save!
    skin
  end

  def self.import_plain_text
    css = File.read(Rails.public_path + "/stylesheets/plain_text_skin.css")
    skin = Skin.find_or_create_by_title_and_official(:title => "Plain Text", :css => css, :public => true, :official => true)
    File.open(Rails.public_path + '/images/skins/previews/plaintext.png', 'rb') {|preview_file| skin.icon = preview_file}
    skin.official = true
    skin.save!
    skin
  end

end
