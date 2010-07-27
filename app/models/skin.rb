class Skin < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_many :preferences

  attr_protected :official

  validates_uniqueness_of :title, :message => t('skin_title_already_used', :default => 'must be unique')

  named_scope :public_skins, :conditions => {:public => true}
  named_scope :approved_skins, :conditions => {:official => true, :public => true}
  named_scope :unapproved_skins, :conditions => {:public => true, :official => false}

  def remove_me_from_preferences
    Preference.update_all("skin_id = #{Skin.default.id}", "skin_id = #{self.id}")
  end

  def self.create_default
    skin = Skin.new(:title => "Default", :css => "", :public => true)
    skin.official = true
    skin.save
    skin
  end

  def self.default
    Skin.find_by_title("Default") || Skin.create_default
  end

  def self.create_light
     css = <<EOF
body {
background-color: white;
color: black !important;
}
EOF
    skin = Skin.new(:title => "Light", :css => css, :public => true)
    skin.official = true
    skin.save
    skin
  end

  def self.light?(skin_param)
     return false if skin_param == 'creator'
     return true if skin_param == 'light'
     return false unless User.current_user.is_a? User
     return true if User.current_user.try(:preference).try(:skin).try(:title) == "Light"
     return false
  end

  def self.import_plain_text
    css = File.read(Rails.public_path + "/stylesheets/plain_text_skin.css")
    skin = Skin.new(:title => "Plain Text", :css => css, :public => true)
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
