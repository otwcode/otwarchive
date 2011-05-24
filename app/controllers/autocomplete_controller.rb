class AutocompleteController < ApplicationController
  respond_to :json
  
  skip_before_filter :store_location
  skip_before_filter :set_current_user
  skip_before_filter :fetch_admin_settings
  skip_before_filter :set_redirects
  skip_before_filter :sanitize_params # can we dare!


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
  def character_in_fandom; render_redis_output(redis_fandom_tag_lookup(params[:term], "character", params[:fandom], params[:fallback] || true)); end
  def relationship_in_fandom; render_redis_output(redis_fandom_tag_lookup(params[:term], "relationship", params[:fandom], params[:fallback] || true)); end
  
  

  # find people signed up for a challenge
  def challenge_participants
    search_param = params[:term]
    collection_id = params[:collection_id]
    render_output(Pseud.limit(10).order(:name).joins(:challenge_signups)
                    .where(["pseuds.name LIKE ? AND challenge_signups.collection_id = ?", 
                            '%' + search_param + '%', collection_id]).map(&:byline))
  end

  # works for any tag class where what you want to return are the names
  def noncanonical_tag_finder(tag_class, search_param)
    if search_param
      render_output(tag_class.by_popularity
                      .where(["canonical = 0 AND name LIKE ?",
                              '%' + search_param + '%']).limit(10).map(&:name))
    end
  end

  def collection_parent_name
    render_output(current_user.maintained_collections.top_level.with_name_like(params[:collection_parent_name]).map(&:name).sort)
  end

  def collection_filters_title
    unless params[:collection_filters_title].blank?
      render_output(Collection.where(["parent_id IS NULL AND title LIKE ?", '%' + params[:collection_filters_title] + '%']).limit(10).order(:title).map(&:title))    
    end
  end

  def external_work_url
    unless params[:external_work_url].blank?
      render_output(ExternalWork.where(["url LIKE ?", '%' + params[:external_work_url] + '%']).limit(10).order(:url).map(&:url))    
    end    
  end
  
  def bookmark_external_url
    unless params[:bookmark_external_url].blank?
      render_output(ExternalWork.where(["url LIKE ?", '%' + params[:bookmark_external_url] + '%']).limit(10).order(:url).map(&:url))    
    end    
  end
  
  # encodings for importing
  def encoding
    encodings = Encoding.name_list + Encoding.name_list.map {|e| e.downcase}
    set_finder(params[:term], encodings)              
  end
  
  
private

  def render_redis_output(search_param, results)
    render_output(sort_redis_results(search_param, results))
  end

  def render_output(result_strings)
    if result_strings.first.is_a?(String)
      respond_with(result_strings.map {|str| {:id => str, :name => str, :label => str, :value => str}})
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

  
public
  
  ###### all the field-specific methods go here 
  
  # tag wrangling finders
  def tag_syn_string
    tag_finder(params[:type].constantize, params[:tag_syn_string])
  end

  def tag_merger_string
    noncanonical_tag_finder(params[:type].constantize, params[:tag_merger_string])
  end
  
  def tag_media_string
    tag_finder(Media, params[:tag_media_string])
  end 
  
  def tag_meta_tag_string
    tag_finder(params[:type].constantize, params[:tag_meta_tag_string])
  end
  
  def tag_sub_tag_string
    tag_finder(params[:type].constantize, params[:tag_sub_tag_string])
  end
  
end

