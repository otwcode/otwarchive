class AutocompleteController < ApplicationController
  respond_to :json
  
  skip_before_filter :store_location
  skip_before_filter :set_current_user
  skip_before_filter :fetch_admin_settings
  skip_before_filter :set_redirects
  skip_before_filter :sanitize_params # can we dare!

  before_filter :require_term, :except => [:tag_in_fandom, :relationship_in_fandom, :character_in_fandom]
  
  def require_term
    if params[:term].blank?
      flash[:error] = ts("What were you trying to autocomplete?")
      redirect_to(request.env["HTTP_REFERER"] || root_path) and return
    end
  end

  # ACTIONS GO HERE
  
  # look up pseuds ranked alphabetically
  def pseud
    render_redis_output(params[:term], Pseud.redis_lookup(params[:term]))
  end
  
  
  # look up collections ranked by number of items they contain
  def collection
    # collections are stored as id-fullname
    results = Collection.redis_lookup(params[:term], include="all").map {|result| result.split("-",2)[1]}
    render_redis_output(params[:term], results)
  end

  def open_collection
    results = Collection.redis_lookup(params[:term], include="open").map {|result| result.split("-",2)[1]}
    render_redis_output(params[:term], results)
  end
  
  def closed_collection
    results = Collection.redis_lookup(params[:term], include="closed").map {|result| result.split("-",2)[1]}
    render_redis_output(params[:term], results)
  end

  
  # look up tags ranked by order of their popularity
  def tag
    render_redis_output(params[:term], Tag.redis_lookup(params[:term], params[:type]))
  end
  # these are all duplicates of "tag" but make our calls to autocomplete more readable
  def fandom; render_redis_output(params[:term], Tag.redis_lookup(params[:term], "fandom")); end
  def character; render_redis_output(params[:term], Tag.redis_lookup(params[:term], "character")); end
  def relationship; render_redis_output(params[:term], Tag.redis_lookup(params[:term], "relationship")); end
  def freeform; render_redis_output(params[:term], Tag.redis_lookup(params[:term], "freeform")); end

  def tag_in_set
    render_redis_output(redis_tag_lookup(params[:term], params[:type], params[:tag_set_id])) 
  end
  
  def tag_in_fandom
    render_redis_output(redis_fandom_tag_lookup(params[:term], params[:type], params[:fandom], params[:fallback] || true)) 
  end
  # duplicates of tag_in_fandom
  def character_in_fandom; render_redis_output(params[:term], Tag.redis_fandom_lookup(params[:term], "character", params[:fandom], params[:fallback] || true)); end
  def relationship_in_fandom; render_redis_output(params[:term], Tag.redis_fandom_lookup(params[:term], "relationship", params[:fandom], params[:fallback] || true)); end
  

  # noncanonical tags still use db
  def noncanonical_tag
    search_param = params[:term]
    tag_class = params[:type].classify.constantize
    render_output(tag_class.by_popularity
                      .where(["canonical = 0 AND name LIKE ?",
                              '%' + search_param + '%']).limit(10).map(&:name))
  end

  
  # more-specific autocompletes should be added below here when they can't be avoided
  
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

  
  
private

  def render_redis_output(search_param, results)
    render_output(sort_redis_results(search_param, results))
  end

  def render_output(result_strings)
    if result_strings.first.is_a?(String)
      respond_with(result_strings.map {|str| {:id => str, :name => str}})
    else
      respond_with(result_strings)
    end
  end

  def sort_redis_results(search_param, pre_results, limit=15)
    # bump up the results that start with the search param (or have the search param right after a / or & for relationships)
    results = []
    pre_results.each_with_index do |string, index|
      if string.match(/^#{search_param}/i) || string.match(/(\/|\&)\s*#{search_param}/i)
        results << string
        pre_results.delete_at(index)
      end
    end
    results += pre_results
    
    # limit to 15
    Rails.logger.info "param #{search_param}, results: #{results.join(", ")}"
    results[0..limit]
  end

end

