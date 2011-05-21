class AutocompleteController < ApplicationController
  respond_to :json
  
  skip_before_filter :store_location
  skip_before_filter :set_current_user
  skip_before_filter :fetch_admin_settings
  skip_before_filter :set_redirects
  skip_before_filter :sanitize_params # can we dare!


  # ACTIONS GO HERE
  
  def pseud
    render_output(redis_pseud_lookup(params[:term]))
  end
  
  def fandom
    tag_finder("fandom", params[:term])
  end
  
  def character
    tag_finder("character", params[:term])
  end
  
  def relationship
    tag_finder("relationship", params[:term])
  end
  
  def freeform
    tag_finder("freeform", params[:term])
  end
  
  def collection
    render_output(redis_collection_lookup(params[:term], only_open=false))
  end

  def collection_open
    render_output(redis_collection_lookup(params[:term]))
  end
  
  def tag_finder_restricted_by_tag_set
    search_param = params[params[:fieldname]]
    tag_type = params[:tag_type]
    tag_set_id = params[:tag_set_id]
    render_output(redis_tag_lookup(search_param, tag_type, tag_set_id))    
    # tag_set = TagSet.find(params[:tag_set_id])
    # if tag_set.nil?
    #   tag_finder(tag_type.classify, search_param)
    # else
    #   tags = tag_set.tags.with_type(tag_type).by_popularity.where("name LIKE ?", search_param + '%').limit(10)
    #   tags += tag_set.tags.with_type(tag_type).by_popularity.where("name LIKE ?", '%' + search_param + '%').limit(7)
    #   render_output(tags.uniq.map(&:name))
    # end
  end

  # handle relationships specially
  def relationship_finder(search_param)
    if search_param && search_param.match(/(\&|\/)/)
      tag_finder(Relationship, search_param)
    else
      tags = get_tags_for_relationship_finder(search_param)
      render_output(tags.uniq.sort {|a,b| b.taggings_count <=> a.taggings_count}.map(&:name))
    end
  end

  # works for any tag class where what you want to return are the names
  def noncanonical_tag_finder(tag_class, search_param)
    if search_param
      render_output(tag_class.by_popularity
                      .where(["canonical = 0 AND name LIKE ?",
                              '%' + search_param + '%']).limit(10).map(&:name))
    end
  end

  
private

  # works for any tag class where what you want to return are the names
  def tag_finder(tag_class, search_param)
    if search_param
      # tags = get_tags_for_finder(tag_class, search_param)
      # render_output(tags.uniq.map(&:name))
      render_output(redis_tag_lookup(search_param, tag_class))
    end
  end

  def render_output(result_strings, to_highlight="")
    respond_with(result_strings.map {|str| {:id => str, :name => str}})
    # @results = result_strings
    # render :inline  => @results.length > 0 ? "<%= content_tag(:ul, @results.map {|string| content_tag(:li, string)}.join.html_safe) %>" : ""
  end

  def redis_sort_results(search_param, pre_results)
    # bump up the results that actually start with the search param
    results = []
    pre_results.each_with_index do |string, index|
      if string.match(/^#{search_param}/i)
        results << string
        pre_results.delete_at(index)
      end
    end
    results += pre_results
    
    # limit to 15
    results[0..15]
  end

  def redis_tag_lookup(search_param, tag_type = "fandom", tag_set_id = nil)
    redis_key = "autocomplete_tag_#{tag_type}_#{search_param}"
    redis_key += "_#{tag_set_id}" if tag_set_id
    unless $redis.exists(redis_key)
      # create an intersection of all the stored sets of tags 
      sets = search_param.three_letter_sections.map {|section| "autocomplete_tag_#{tag_type}_#{section}"}
      sets.unshift "autocomplete_tagset_#{tag_set_id}" if tag_set_id
      $redis.zinterstore(redis_key, sets, :aggregate => :max)
      $redis.expire(redis_key, 60*ArchiveConfig.TAG_AUTOCOMPLETE_EXPIRATION_TIME) if sets.length > 1
    end
    
    # now we get out 20 of the tags sorted by popularity
    redis_sort_results(search_param, $redis.zrevrange(redis_key, 0, 20))
  end

  def redis_pseud_lookup(search_param)
    redis_key = "autocomplete_pseud_#{search_param}"
    sets = search_param.three_letter_sections.map {|section| "autocomplete_pseud_#{section}"}
    $redis.zinterstore(redis_key, sets, :aggregate => :max)
    redis_sort_results(search_param, $redis.zrange(redis_key, 0, -1))
  end

  def redis_collection_lookup(search_param, only_open=true)
    redis_key = "autocomplete_collection_open_#{search_param}"
    sets = search_param.three_letter_sections.map {|section| "autocomplete_collection_open_#{section}"}
    $redis.zinterstore(redis_key, sets, :aggregate => :max)
    
    if only_open
      redis_sort_results(search_param, $redis.zrange(redis_key, 0, -1))
    else
      redis_key2 = "autocomplete_collection_closed_#{search_param}"
      sets = search_param.three_letter_sections.map {|section| "autocomplete_collection_closed_#{section}"}
      $redis.zinterstore(redis_key2, sets, :aggregate => :max)
      redis_combined_key = "autocomplete_collection_all_#{search_param}"
      $redis.zunionstore(redis_combined_key, 2, redis_key, redis_key2)
      redis_sort_results(search_param, $redis.zrange(redis_combined_key, 0, -1))
    end
  end

  def get_tags_for_relationship_finder(search_param)
    tags = Relationship.canonical.by_popularity
                        .where("name LIKE ? OR name LIKE ? OR name LIKE ?", 
                                search_param + '%', '%/' + search_param + '%',
                                '%& ' + search_param + '%').limit(15)
  end


  # somewhere in the params is a potentially deeply nested hash with the given fieldname
  def get_fandoms_from_params(params, fieldname)
    hash = params
    nexthash = nil

    while hash.is_a? Hash
      hash.keys.each do |key|
        if key == fieldname
          # we've found the fandoms
          fandom_names = hash[key]
          if fandom_names.is_a? String
            return [] if fandom_names.blank?
            return fandom_names.split(',').delete_if {|fname| fname.blank?}.collect {|fname| Fandom.find_by_name(fname.strip)}.compact
          elsif fandom_names.is_a? Array
            return fandom_names.collect {|fname| Fandom.find_by_name(fname.strip)}.compact
          end
        elsif hash[key].is_a? Hash
          nexthash = hash[key]
        end
      end
      hash = nexthash
    end
    
    return []
  end

  
public

  # this finder only returns characters that are children of the given fandom
  def character_finder_restricted_by_fandom
    search_param = params[:term]
    fandoms = get_fandoms_from_params(params, params[:fandom_fieldname])
    message = ""
    if fandoms.empty?
      message = ts("- No valid fandoms selected! -")
      tags = search_param.blank? ? [] : get_tags_for_finder(Character, search_param)
    elsif search_param.blank?
      tags = Character.with_parents(fandoms).canonical.by_popularity.limit(10)
    else
      tags = Character.with_parents(fandoms).canonical.by_popularity.where("tags.name LIKE ?", '%' + search_param + '%').limit(10)
    end
    if !fandoms.empty? && tags.empty?
      message = ts("- No matching characters found in selected fandoms! -") unless params[:no_alert]
      tags = get_tags_for_finder(Character, search_param)
    end
    results = message.blank? ? [] : [message]
    results += tags.uniq.map(&:name)
    render_output(results)
  end

  # this finder only returns relationships that are children of the given fandom
  def relationship_finder_restricted_by_fandom
    search_param = params[:term]
    fandoms = get_fandoms_from_params(params, params[:fandom_fieldname])
    message = ""
    if fandoms.empty?
      message = ts("- No valid fandoms selected! -")
      tags = search_param.blank? ? [] : get_tags_for_relationship_finder(search_param)
    elsif search_param.blank?
      tags = Relationship.with_parents(fandoms).canonical.by_popularity.limit(10)
    else
      tags = Relationship.with_parents(fandoms).canonical.by_popularity.where("tags.name LIKE ? OR tags.name LIKE ? OR tags.name LIKE ?", 
                                                                                      search_param + '%', '%/' + search_param + '%',
                                                                                      '%& ' + search_param + '%').limit(10)
    end
    if !fandoms.empty? && tags.empty?
      message = ts("- No matching relationships found in selected fandoms! -") unless params[:no_alert]
      tags = get_tags_for_relationship_finder(search_param)
    end
    results = message.blank? ? [] : [message]
    results += tags.uniq.map(&:name)
    render_output(results)
  end
  
  # find people signed up for a challenge
  def challenge_participants
    search_param = params[:term]
    collection_id = params[:collection_id]
    render_output(Pseud.limit(10).order(:name).joins(:challenge_signups)
                    .where(["pseuds.name LIKE ? AND challenge_signups.collection_id = ?", 
                            '%' + search_param + '%', collection_id]).map(&:byline))
  end

  ###### all the field-specific methods go here 
  
  # pseud-finder methods -- to add a new one, just put the name of the field into the 
  # %w list
  %w(work_recipients participants_to_invite pseud_byline).each do |field|
    define_method("#{field}") do
      pseud_finder(params[:term])
    end
  end
  
  # to handle the autocomplete requests for each type from the nested prompt form, using define_method to set up all
  # the different tag types
  %w(rating category warning).each do |tag_type| 
    define_method("canonical_#{tag_type}_finder") do
      tag_finder("#{tag_type}".classify.constantize, params[:term])
    end
  end 

  # generic canonical tag finders
  %w(canonical_tag_finder tag_string bookmark_tag_string).each do |field|
    define_method("#{field}") do
      tag_finder(Tag, params[:term])
    end
  end

  # fandom finders
  %w(canonical_fandom_finder work_fandom fandom_string tag_fandom_string collection_filters_fandom bookmark_external_fandom_string ).each do |field|
    define_method("#{field}") do
      tag_finder(Fandom, params[:term])
    end
  end

  # relationship finders
  %w(canonical_relationship_finder work_relationship tag_relationship_string bookmark_external_relationship_string).each do |field|
    define_method("#{field}") do
      relationship_finder(params[:term]) 
    end
  end

  # character finders
  %w(canonical_character_finder character_string work_character tag_character_string bookmark_external_character_string).each do |field|
    define_method("#{field}") do
      tag_finder(Character, params[:term])
    end
  end

  # freeform finders
  %w(canonical_freeform_finder work_freeform tag_freeform_string).each do |field|
    define_method("#{field}") do
      tag_finder(Freeform, params[:term])
    end
  end  
  
  # collection name finders
  %w(collection_names work_collection_names).each do |field|
    define_method("#{field}") do
      collection_finder(params[:term])
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
  
end

