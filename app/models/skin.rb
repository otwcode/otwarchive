class Skin < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_many :preferences
  
  has_attached_file :icon,
  :styles => { :standard => "100x100>" },
  :url => "/system/:class/:attachment/:id/:style/:basename.:extension", 
  :path => ENV['RAILS_ENV'] == 'production' ? ":class/:attachment/:id/:style.:extension" : ":rails_root/public:url",  
  :storage => ENV['RAILS_ENV'] == 'production' ? :s3 : :filesystem,
  :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
  :bucket => ENV['RAILS_ENV'] == 'production' ? YAML.load_file("#{RAILS_ROOT}/config/s3.yml")['bucket'] : "",
  :default_url => "/images/skin_preview_none.png"
   
  ICON_ALT_MAX = 50
  
  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true 
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true 
  validates_length_of :icon_alt_text, :allow_blank => true, :maximum => ICON_ALT_MAX,
    :too_long => t('icon_alt_too_long', :default => "must be less than {{max}} characters long.", :max => ICON_ALT_MAX)

  attr_protected :official

  validates_uniqueness_of :title, :message => t('skin_title_already_used', :default => 'must be unique')

  named_scope :public_skins, :conditions => {:public => true}
  named_scope :approved_skins, :conditions => {:official => true, :public => true}
  named_scope :unapproved_skins, :conditions => {:public => true, :official => false}

  def remove_me_from_preferences
    Preference.update_all("skin_id = #{Skin.default.id}", "skin_id = #{self.id}")
  end

  def self.create_default
    skin = Skin.find_or_create_by_title(:title => "Default", :css => "", :public => true)
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
