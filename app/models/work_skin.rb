class WorkSkin < Skin
  include SkinCacheHelper

  has_many :works
  after_save :skin_invalidate_cache

  # override parent's clean_css to append a prefix
  def clean_css
    return if self.css.blank?
    check = lambda {|ruleset, property, value|
      # If it starts with --, assume the user was trying to define a custom property.
      if property.match(/\A--/)
        errors.add(:base, :work_skin_custom_properties)
        return false
      end
      if value.match(/\A(#{CssCleaner::VAR_FUNCTION_REGEX})\z/)
        errors.add(:base, :work_skin_var)
        return false
      end
      if property == "position" && value == "fixed"
        # Do not internationalize the , used as a join in this error -- it's reflective of the comma used in the list of selectors, which does not change based on locale.
        errors.add(:base, :work_skin_banned_value_for_property, property: property, selectors: ruleset.selectors.join(", "), value: value)
        return false
      end
      return true
    }
    options = {prefix: "#workskin", caller_check: check}
    self.css = clean_css_code(self.css, options)
  end

  def self.model_name
    # re-use the model_name of the superclass (Skin)
    self.superclass.model_name
  end

  def self.basic_formatting
    Skin.find_by(title: "Basic Formatting", official: true) || WorkSkin.import_basic_formatting
  end

  def self.import_basic_formatting
    css = File.read(File.join(Rails.public_path, "/stylesheets/work_skins/basic_formatting.css"))
    skin = WorkSkin.find_or_create_by(title: "Basic Formatting", css: css, role: "user", public: true, official: true)
    skin.icon.attach(
      io: File.open(File.join(Rails.public_path, "/images/skins/previews/basic_formatting.png"), "rb"),
      filename: "basic_formatting.png",
      content_type: "image/png"
    )
    skin.official = true
    skin.save!
    skin
  end
end
