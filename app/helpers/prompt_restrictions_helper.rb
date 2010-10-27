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
    
    result = "<!-- prompt restriction settings helper function -->".html_safe
    result += content_tag(:dt, form.label(:optional_tags_allowed, ts("Optional Tags?")) +
                          link_to_help("challenge-optional-tags"))
    result += content_tag(:dd, form.check_box(:optional_tags_allowed))

    result += content_tag(:dt, form.label(:description_allowed, ts("Details/Description:")))
    result += required_and_allowed_boolean(form, "description")

    result += content_tag(:dt, form.label(:url_required, ts("URL:")))
    result += required_and_allowed_boolean(form, "url")
    
    result += content_tag(:dt, form.label(:fandom_num_required, ts("Fandom(s):")))
    result += required_and_allowed(form, "fandom")

    result += content_tag(:dt, form.label(:character_num_required, ts("Character(s):")))
    result += required_and_allowed(form, "character")

    result += content_tag(:dt, form.label(:relationship_num_required, ts("Relationship(s):")))
    result += required_and_allowed(form, "relationship")

    result += content_tag(:dt, form.label(:rating_num_required, ts("Rating(s):")))
    result += required_and_allowed(form, "rating")

    result += content_tag(:dt, form.label(:category_num_required, ts("Categories:")))
    result += required_and_allowed(form, "category")

    result += content_tag(:dt, form.label(:freeform_num_required, ts("Freeform(s):")))
    result += required_and_allowed(form, "freeform")

    result += content_tag(:dt, form.label(:warning_num_required, ts("Archive Warning(s):")))
    result += required_and_allowed(form, "warning")
  end
  
  def required_and_allowed_boolean(form, fieldname)
    content_tag(:dd, ("Required: " + form.check_box( ("#{fieldname}_required").to_sym) + 
               " Allowed: " + form.check_box( ("#{fieldname}_allowed").to_sym) ).html_safe )
  end
  
  def required_and_allowed(form, tag_type)
    fields = "Required: " + form.text_field( ("#{tag_type}_num_required").to_sym, :size => 1 )
    fields += " Allowed: " + form.text_field( ("#{tag_type}_num_allowed").to_sym, :size => 2 )
    if TagSet::TAG_TYPES.include?(tag_type)
      fields += " Allow Any? " + form.check_box("allow_any_#{tag_type}".to_sym)
      fields += " Must Be Unique? " + form.check_box("require_unique_#{tag_type}".to_sym)
    end
    content_tag(:dd, fields.html_safe)
  end  

end
