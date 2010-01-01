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
  
  def bookmark_external_fandom_string ; tag_finder(Fandom, params[:bookmark_external_fandom_string]) ; end
  def bookmark_external_character_string ; tag_finder(Character, params[:bookmark_external_character_string]) ; end
  def bookmark_external_pairing_string ; tag_finder(Pairing, params[:bookmark_external_pairing_string]) ; end

  
end
