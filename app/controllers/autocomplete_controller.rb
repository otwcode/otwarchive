class AutocompleteController < ApplicationController
  respond_to :json
  
  skip_before_filter :store_location
  skip_before_filter :set_current_user, :except => [:collection_parent_name, :owned_tag_sets]
  skip_before_filter :fetch_admin_settings
  skip_before_filter :set_redirects
  skip_before_filter :sanitize_params # can we dare!

  before_filter :require_term, :except => [:tag_in_fandom, :relationship_in_fandom, :character_in_fandom, :fandom_for_child]
  
  def require_term
    if params[:term].blank?
      flash[:error] = ts("What were you trying to autocomplete?")
      redirect_to(request.env["HTTP_REFERER"] || root_path) and return
    end
  end

  #########################################
  ############# LOOKUP ACTIONS GO HERE
  
  # PSEUDS
  def pseud
    render_output(Pseud.autocomplete_lookup(params[:term], "autocomplete_pseud").map {|res| Pseud.fullname_from_autocomplete(res)})
  end
  
  ## TAGS  
  def tag
    render_output(tag_output(params[:term], params[:type]))
  end
  # these are all duplicates of "tag" but make our calls to autocomplete more readable
  def fandom; render_output(tag_output(params[:term], "fandom")); end
  def character; render_output(tag_output(params[:term], "character")); end
  def relationship; render_output(tag_output(params[:term], "relationship")); end
  def freeform; render_output(tag_output(params[:term], "freeform")); end


  ## TAGS IN SET
  def tag_in_set
    render_output(Tag.autocomplete_lookup(params[:term], "autocomplete_tag_#{params[:type]}", :constraint_sets => ["autocomplete_tagset_#{params[:tag_set_id]}"]).map {|r| Tag.name_from_autocomplete(r)})
  end
  
  ## TAGS IN FANDOMS
  def tag_in_fandom
    render_output(tag_in_fandom_output(params[:term], params[:type], params[:fandom], params[:fallback] || true)) 
  end
  def character_in_fandom; render_output(tag_in_fandom_output(params[:term], "character", params[:fandom], params[:fallback] || true)); end
  def relationship_in_fandom; render_output(tag_in_fandom_output(params[:term], "relationship", params[:fandom], params[:fallback] || true)); end
  
  ## Parents for given tag
  def fandom_for_child
    results = Tag.autocomplete_fandom_for_child(params[:term], params[:child]) 
    unless results.empty?
      render_output(results)
    else
      render_output(tag_output(params[:term], "fandom"))
    end
  end

  # Nominated parents
  def nominated_parents
    parents = TagNomination.where(:tagname => params[:tagname]).select("parent_tagname, count(*) as count").group("parent_tagname").order("count DESC")
    if params[:term]
      parents = parents.where("parent_tagname LIKE ?", "%#{params[:term]}%")
    end
    respond_with(parents[:parent_tagname])
  end

  ## NONCANONICAL TAGS
  def noncanonical_tag
    search_param = params[:term]
    tag_class = params[:type].classify.constantize
    render_output(tag_class.by_popularity
                      .where(["canonical = 0 AND name LIKE ?",
                              '%' + search_param + '%']).limit(10).map(&:name))
  end
  
  # determine whether a particular tag is canonical or not
  def is_canonical
    t = Tag.find_by_name(params[:term])
    if t.nil? || !t.canonical
      respond_with(["0"])
    else
      respond_with(["1"])
    end
  end    

  # get the single parent for a child
  def single_fandom_for_child
    if (tag = Tag.where(:name => params[:term]).includes(:parents).first)
      respond_with([tag.parents.order("taggings_count DESC").select {|p| p.is_a? Fandom}.first.name])
    end
  end
  


  
  # more-specific autocompletes should be added below here when they can't be avoided

  
  # look up collections ranked by number of items they contain

  def collection_fullname
    results = Collection.autocomplete_lookup(params[:term], "autocomplete_collection_all").map {|res| Collection.fullname_from_autocomplete(res)}
    render_output(results)
  end

  # return collection names
  
  def open_collection_names
    # in this case we want different ids from names so we can display the title but only put in the name
    results = Collection.autocomplete_lookup(params[:term], "autocomplete_collection_open").map do |str| 
      {:id => Collection.name_from_autocomplete(str), :name => Collection.title_from_autocomplete(str)}
    end
    respond_with(results)
  end
  
  # For creating collections, autocomplete the name of a parent collection owned by the user only
  def collection_parent_name
    render_output(current_user.maintained_collections.top_level.with_name_like(params[:term]).map(&:name).sort)
  end

  # for looking up existing urls for external works to avoid duplication 
  def external_work
    render_output(ExternalWork.where(["url LIKE ?", '%' + params[:term] + '%']).limit(10).order(:url).map(&:url))    
  end
  
  # encodings for importing
  def encoding
    encodings = Encoding.name_list.select {|e| e.match(/#{params[:term]}/i)}
    render_output(encodings)
  end

  # people signed up for a challenge
  def challenge_participants
    search_param = params[:term]
    collection_id = params[:collection_id]
    render_output(Pseud.limit(10).order(:name).joins(:challenge_signups)
                    .where(["pseuds.name LIKE ? AND challenge_signups.collection_id = ?", 
                            '%' + search_param + '%', collection_id]).map(&:byline))
  end
  
  # owned tag sets that are visible
  def owned_tag_sets
    if params[:term].length > 0
      search_param = '%' + params[:term] + '%'
      render_output(OwnedTagSet.limit(10).order(:title).usable.where("owned_tag_sets.title LIKE ?", search_param).collect(&:title))
    end
  end
  
  # owned tag sets that are visible and open to nominations
  # returns title and id
  def nominated_tag_sets
    if params[:term].length > 0
      search_param = '%' + params[:term] + '%'
      results = OwnedTagSet.limit(10).order(:title).visible.where(:nominated => true).where("owned_tag_sets.title LIKE ?", search_param)
      respond_with(results.map {|ots| {:id => ots.id, :name => ots.name}})
    end
  end
  
private

  def render_output(result_strings)
    if result_strings.first.is_a?(String)
      respond_with(result_strings.map {|str| {:id => str, :name => str}})
    else
      respond_with(result_strings)
    end
  end
  
  def tag_output(search_param, tag_type)
    Tag.autocomplete_lookup(search_param, "autocomplete_tag_#{tag_type}").map {|r| Tag.name_from_autocomplete(r)}
  end
  
  def tag_in_fandom_output(search_param, tag_type, fandom, fallback = true)
    Tag.autocomplete_fandom_lookup(search_param, tag_type, fandom, fallback).map {|r| Tag.name_from_autocomplete(r)}
  end
end

