module PromptRestrictionsHelper

  def get_prompt_restriction(for_offer=false)
    if @collection && @collection.challenge
      if for_offer
        @collection.challenge.offer_restriction || @collection.challenge.prompt_restriction
      else
        @collection.challenge.request_restriction || @collection.challenge.prompt_restriction
      end
    end
  end
  
  def prompt_restriction_settings(form, include_description = false)
    
    result = "<!-- prompt restriction settings helper function -->"
    result += dt_wrapper(form.label(:optional_tags_allowed, t('prompt_restrictions.optional_tags_allowed', :default => "Optional Tags?")) +
                          link_to_help("challenge-optional-tags"))
    result += dd_wrapper(form.check_box(:optional_tags_allowed))

    result += dt_wrapper(form.label(:description_allowed, t('prompt_restrictions.description_allowed', :default => "Details/Description: ")))
    result += required_and_allowed_boolean(form, "description")

    result += dt_wrapper(form.label(:url_required, t('prompt_restrictions.url_required', :default => "URL: ")))
    result += required_and_allowed_boolean(form, "url")

    result += dt_wrapper(form.label(:fandom_num_required, t('prompt_restrictions.fandom_num_required', :default => "Fandom(s): ")))
    result += required_and_allowed(form, "fandom")

    result += dt_wrapper(form.label(:character_num_required, t('prompt_restrictions.character_num_required', :default => "Character(s): ")))
    result += required_and_allowed(form, "character")

    result += dt_wrapper(form.label(:pairing_num_required, t('prompt_restrictions.pairing_num_required', :default => "Pairing(s):")))
    result += required_and_allowed(form, "pairing")

    result += dt_wrapper(form.label(:rating_num_required, t('prompt_restrictions.rating_num_required', :default => "Rating(s):")))
    result += required_and_allowed(form, "rating")

    result += dt_wrapper(form.label(:category_num_required, t('prompt_restrictions.category_num_required', :default => "Categories:")))
    result += required_and_allowed(form, "category")

    result += dt_wrapper(form.label(:freeform_num_required, t('prompt_restrictions.freeform_num_required', :default => "Freeform(s):")))
    result += required_and_allowed(form, "freeform")

    result += dt_wrapper(form.label(:warning_num_required, t('prompt_restrictions.warning_num_required', :default => "Archive Warning(s):")))
    result += required_and_allowed(form, "warning")
  end
  
  def required_and_allowed_boolean(form, fieldname)
    dd_wrapper("Required: #{form.check_box( (fieldname + "_required").to_sym)}" + 
               " Allowed: #{form.check_box( (fieldname + "_allowed").to_sym)}")
  end
  
  def required_and_allowed(form, tag_type)
    dd_wrapper("Required: #{form.text_field( (tag_type + "_num_required").to_sym, :size => 1 )}" + 
               " Allowed: #{form.text_field( (tag_type + "_num_allowed").to_sym, :size => 2 )}")
  end
  
  def dt_wrapper(string)
    return "<dt>#{string}</dt>"
  end
  
  def dd_wrapper(string)
    return "<dd>#{string}</dd>"
  end
  

end
