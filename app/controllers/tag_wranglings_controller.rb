class TagWranglingsController < ApplicationController   
  
  permit "tag_wrangler", :permission_denied_message => "Sorry, the page you tried to access is for authorized tag wranglers only.".t
  before_filter :check_user_status
  
  def index
    @fandom = Fandom.find(params[:fandom_id]) if params[:fandom_id]
    if @fandom
      @works = @fandom.works.recent
    end
    @tag = Tag.find(params[:tag_id]) if params[:tag_id]
    if @tag
      @works = @tag.works.recent
      @canonical = @tag.class.canonical || []
    end
    @tags = Tag.find_all_by_id(params[:tag_ids]) if params[:tag_ids]
    if @tags
      @klass = @tags.first.class
      @works = Work.with_any_tags(@tags).recent
    end
    if @fandom.blank? && @tags.blank? && @tag.blank?
      @by_fandom = []
      invalid_fandoms = Fandom.all - Fandom.valid
      no_fandom = Tag.unwrangled.by_fandom(invalid_fandoms) + Tag.unwrangled.find_all_by_fandom_id(nil) 
      @by_fandom << [nil, no_fandom.group_by(&:type)]
      Fandom.valid.sort.each do |fandom|
        unwrangled = Tag.unwrangled.by_fandom(fandom)
        @by_fandom << [fandom, unwrangled.group_by(&:type)] unless unwrangled.blank?
      end
    end
    respond_to do |format|
      format.html 
      format.js
    end
    
  end
  
end
