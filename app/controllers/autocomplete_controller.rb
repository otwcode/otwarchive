class AutocompleteController < ApplicationController
  skip_before_filter :store_location

  def render_output(result_strings, to_highlight="")
    @results = result_strings
    render :inline  => @results.length > 0 ? "<ul><%= @results.map {|string| '<li>' + string + '</li>'} %></ul>" : ""
  end

  # works for finding items in any set
  def set_finder(search_param, set)
    render_output(set.grep(/#{search_param}/).to_a.sort) unless search_param.blank?
  end

  # works for any tag class where what you want to return are the names
  def tag_finder(tag_class, search_param)
    if search_param
      tags = tag_class.canonical.order('taggings_count DESC').where("name LIKE ?", search_param + '%'], :limit => 10)
      extra_limit = 10 - tags.size + 5
      tags += tag_class.canonical.order('taggings_count DESC').where(["name LIKE ?", '%' + search_param + '%']).limit(extra_limit)
      render_output(tags.uniq.map(&:name))
    end
  end
  
  # handle relationships specially
  def relationship_finder(search_param)
    if search_param && search_param.match(/(\&|\/)/)
      tag_finder(Relationship, search_param)
    else
      tags = Relationship.canonical.order('taggings_count DESC')
        .where(["name LIKE ? OR name LIKE ? OR name LIKE ?", 
                search_param + '%', '%/' + search_param + '%',
                '%& ' + search_param + '%']).limit(15)
      render_output(tags.uniq.sort {|a,b| b.taggings_count <=> a.taggings_count}.map(&:name))
    end
  end
  
  # works for any tag class where what you want to return are the names
  def noncanonical_tag_finder(tag_class, search_param)
    if search_param
      render_output(tag_class.order('taggings_count DESC')
                      .where(["canonical = 0 AND name LIKE ?",
                              '%' + search_param + '%']).limit(10).map(&:name))
    end
  end

  def pseud_finder(search_param)
    if search_param
      render_output(Pseud.order(:name).where(["name LIKE ?", '%' + search_param + '%']).limit(10).map(&:byline))
    end
  end
  
  def collection_finder(search_param)
    render_output(Collection.open.with_name_like(search_param).name_only.map(&:name).sort)
  end

  # find people signed up for a challenge
  def challenge_participants
    search_param = params[params[:fieldname]]
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
      pseud_finder(params[params[:fieldname]])
    end
  end
  
  # to handle the autocomplete requests for each type from the nested prompt form, using define_method to set up all
  # the different tag types
  %w(rating category warning).each do |tag_type| 
    define_method("canonical_#{tag_type}_finder") do
      tag_finder("#{tag_type}".classify.constantize, params[params[:fieldname]])
    end
  end 

  # generic canonical tag finders
  %w(canonical_tag_finder tag_string bookmark_tag_string).each do |field|
    define_method("#{field}") do
      tag_finder(Tag, params[params[:fieldname]])
    end
  end

  # fandom finders
  %w(canonical_fandom_finder fandom_string work_fandom tag_fandom_string collection_filters_fandom bookmark_external_fandom_string ).each do |field|
    define_method("#{field}") do
      tag_finder(Fandom, params[params[:fieldname]])
    end
  end

  # relationship finders
  %w(canonical_relationship_finder work_relationship tag_relationship_string bookmark_external_relationship_string).each do |field|
    define_method("#{field}") do
      relationship_finder(params[params[:fieldname]]) 
    end
  end

  # character finders
  %w(canonical_character_finder character_string work_character tag_character_string bookmark_external_character_string).each do |field|
    define_method("#{field}") do
      tag_finder(Character, params[params[:fieldname]])
    end
  end

  # freeform finders
  %w(canonical_freeform_finder work_freeform tag_freeform_string).each do |field|
    define_method("#{field}") do
      tag_finder(Freeform, params[params[:fieldname]])
    end
  end  
  
  # collection name finders
  %w(collection_names work_collection_names).each do |field|
    define_method("#{field}") do
      collection_finder(params[params[:fieldname]])
    end
  end

  def collection_parent_name
    render_output(current_user.maintained_collections.top_level.with_name_like(params[:collection_parent_name]).name_only.map(&:name).sort)
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
  
  # css finders for skins
  def css_keyword
    set_finder(params[params[:fieldname]], HTML::WhiteListSanitizer.allowed_css_keywords)
  end
  
end

