class AutocompleteController < ApplicationController

  def render_output(result_strings)
    @results = result_strings
    render :inline  => "<ul><%= @results.map {|string| '<li>' + string + '</li>'} -%></ul>"
  end

  # works for any tag class where what you want to return are the names
  def tag_finder(tag_class, search_param)
    if search_param
      render_output(tag_class.canonical.find(:all, :order => :name, :conditions => ["name LIKE ?", '%' + search_param + '%'], :limit => 10).map(&:name))
    end
  end
  
  # works for any tag class where what you want to return are the names
  def noncanonical_tag_finder(tag_class, search_param)
    if search_param
      render_output(tag_class.find(:all, :order => :name, :conditions => ["canonical = 0 AND name LIKE ?", '%' + search_param + '%'], :limit => 10).map(&:name))
    end
  end

  def pseud_finder(search_param)
    if search_param
      render_output(Pseud.find(:all, :order => :name, :conditions => ["name LIKE ?", '%' + search_param + '%'], :limit => 10).map(&:byline))
    end
  end
  
  def collection_finder(search_param)
    render_output(Collection.open.with_name_like(search_param).name_only.map(&:name).sort)
  end

  ## field-specific methods 
  
  def collection_names
    collection_finder(params[:collection_names])
  end
  
  def work_collection_names
    collection_finder(params[:work_collection_names])
  end
  
  def collection_parent_name
    render_output(current_user.maintained_collections.top_level.with_name_like(params[:collection_parent_name]).name_only.map(&:name).sort)
  end

  def participants_to_invite
    pseud_finder(params[:participants_to_invite])
  end
    
  def work_recipients
    pseud_finder(params[:work_recipients])
  end
  
  def work_fandom
    tag_finder(Fandom, params[:work_fandom])
  end
  
  def work_pairing
    tag_finder(Pairing, params[:work_pairing])
  end

  def work_character
    tag_finder(Character, params[:work_character])
  end

  def work_freeform
    tag_finder(Freeform, params[:work_freeform])
  end

  def tag_string
    tag_finder(Tag, params[:tag_string])
  end

  # tag wrangling
  
  def tag_syn_string
    tag_finder(params[:type].constantize, params[:tag_syn_string])
  end

  def tag_merger_string
    noncanonical_tag_finder(params[:type].constantize, params[:tag_merger_string])
  end
  
  def tag_media_string
    tag_finder(Media, params[:tag_media_string])
  end 
  def tag_fandom_string
    tag_finder(Fandom, params[:tag_fandom_string])
  end  
  def tag_character_string
    tag_finder(Character, params[:tag_character_string])
  end  
  def tag_pairing_string
    tag_finder(Pairing, params[:tag_pairing_string])
  end  
  def tag_freeform_string
    tag_finder(Freeform, params[:tag_freeform_string])
  end    
  def tag_meta_tag_string
    tag_finder(params[:type].constantize, params[:tag_meta_tag_string])
  end
  def tag_sub_tag_string
    tag_finder(params[:type].constantize, params[:tag_sub_tag_string])
  end   
  
  def bookmark_external_fandom_string ; tag_finder(Fandom, params[:bookmark_external_fandom_string]) ; end
  def bookmark_external_character_string ; tag_finder(Character, params[:bookmark_external_character_string]) ; end
  def bookmark_external_pairing_string ; tag_finder(Pairing, params[:bookmark_external_pairing_string]) ; end
  def fandom_string ; tag_finder(Fandom, params[:fandom_string]) ; end
  def character_string ; tag_finder(Character, params[:character_string]) ; end
  
  def collection_filters_title
    render_output(Collection.find(:all, :conditions => ["parent_id IS NULL AND title LIKE ?", params[:collection_filters_title] + '%'], :limit => 10, :order => :title).map(&:title))    
  end
  def collection_filters_fandom
    tag_finder(Fandom, params[:collection_filters_fandom])
  end
  
end
