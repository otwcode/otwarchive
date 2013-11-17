class TagWranglingsController < ApplicationController
  cache_sweeper :tag_sweeper 
  
  before_filter :check_user_status
	before_filter :check_permission_to_wrangle

  def index
    @counts = {}
    [Fandom, Character, Relationship, Freeform].each do |klass|
      @counts[klass.to_s.downcase.pluralize.to_sym] = klass.unwrangled.in_use.count
    end
    unless params[:show].blank?
      params[:sort_column] = 'created_at' if !valid_sort_column(params[:sort_column], 'tag')
      params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
      sort = params[:sort_column] + " " + params[:sort_direction] 
      if params[:show] == "fandoms"
        @media_names = Media.by_name.value_of(:name)
        @page_subtitle = ts("fandoms")
        @tags = Fandom.unwrangled.in_use.order(sort).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)       
      elsif params[:show] == "character_relationships"
        if params[:fandom_string]
          @fandom = Fandom.find_by_name(params[:fandom_string])
          if @fandom && @fandom.canonical?
            @tags = @fandom.children.by_type("Relationship").canonical.order(sort).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
          else
            flash[:error] = "#{params[:fandom_string]} is not a canonical fandom."
          end
        end
      else # by fandom
        klass = params[:show].classify.constantize        
        @tags = klass.unwrangled.in_use.order(sort).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)               
      end
    end
  end
  
  def wrangle
    params[:page] = '1' if params[:page].blank?
    params[:sort_column] = 'name' if !valid_sort_column(params[:sort_column], 'tag')
    params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
    options = {:show => params[:show], :page => params[:page], :sort_column => params[:sort_column], :sort_direction => params[:sort_direction]}
    unless params[:canonicals].blank?
      canonicals = Tag.find(params[:canonicals])
      canonicals.each do |tag|
        tag.update_attributes(:canonical => true)
      end
    end
    if params[:media] && !params[:selected_tags].blank?
      options.merge!(:media => params[:media])
      @media = Media.find_by_name(params[:media])
      @fandoms = Fandom.find(params[:selected_tags])
      @fandoms.each { |fandom| fandom.add_association(@media) }
    elsif params[:character_string] && !params[:selected_tags].blank?
      options.merge!(:character_string => params[:character_string], :fandom_string => params[:fandom_string])
      @character = Character.find_by_name(params[:character_string])
      if @character && @character.canonical?
        @tags = Tag.find(params[:selected_tags])
        @tags.each { |tag| tag.add_association(@character) }
        flash[:notice] = "#{@tags.length} relationships were wrangled to #{params[:character_string]}."
        redirect_to tag_wranglings_path(options) and return        
      else
        flash[:error] = "#{params[:character_string]} is not a canonical character."
        redirect_to tag_wranglings_path(options) and return     
      end
    elsif params[:fandom_string] && !params[:selected_tags].blank?
      options.merge!(:fandom_string => params[:fandom_string])
      @fandom = Fandom.find_by_name(params[:fandom_string])
      if @fandom && @fandom.canonical?
        @tags = Tag.find(params[:selected_tags])
        @tags.each { |tag| tag.add_association(@fandom) }
      else
        flash[:error] = "#{params[:fandom_string]} is not a canonical fandom."
        redirect_to tag_wranglings_path(options) and return     
      end
    end
    flash[:notice] = "Tags were successfully wrangled!"
    redirect_to tag_wranglings_path(options)            
  end
  
  def discuss
    @comments = Comment.where(:commentable_type => 'Tag').order('updated_at DESC').paginate(:page => params[:page])
  end

end
