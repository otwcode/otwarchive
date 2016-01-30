class WorkSkin < Skin

  has_many :works

  # override parent's clean_css to append a prefix
  def clean_css
    return if self.css.blank?
    check = lambda {|ruleset, property, value|
      if property == "position" && value == "fixed"
        errors.add(:base, ts("The #{property} property in #{ruleset.selectors.join(', ')} cannot have the value #{value} in Work skins, sorry!"))
        return false
      end
      return true
    }
    options = {:prefix => "#workskin", :caller_check => check}
    self.css = clean_css_code(self.css, options)
  end

  def self.model_name
    # re-use the model_name of the superclass (Skin)
    self.superclass.model_name
  end

  def self.basic_formatting
    Skin.find_by_title_and_official("Basic Formatting", true) || WorkSkin.import_basic_formatting
  end

  def self.import_basic_formatting
    css = File.read(Rails.public_path + "/stylesheets/work_skins/basic_formatting.css")
    skin = WorkSkin.find_or_create_by_title_and_official(:title => "Basic Formatting", :css => css, :role => "user", :public => true, :official => true)
    File.open(Rails.public_path + '/images/skins/previews/basic_formatting.png', 'rb') {|preview_file| skin.icon = preview_file}
    skin.official = true
    skin.save!
    skin
  end
end
