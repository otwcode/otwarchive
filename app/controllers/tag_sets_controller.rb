class TagSetsController < ApplicationController
  cache_sweeper :tag_set_sweeper
  
  def show
    @tag_set = TagSet.find(params[:id])
    unless @tag_set
      flash[:error] = ts("Which tag set did you want to inspect?")
      redirect_to root_path and return
    end
      
    if params[:tag_type] && TagSet::TAG_TYPES.include?(params[:tag_type])
      @tag_type = params[:tag_type]
      @tags = @tag_set.with_type(@tag_type)
    else
      @tags = @tag_set.tags
    end
    
    #render :layout => "barebones"
  end

end
