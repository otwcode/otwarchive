class TagWranglingsController < ApplicationController   
  
  permit "tag_wrangler", :permission_denied_message => "Sorry, the page you tried to access is for authorized tag wranglers only.".t
  before_filter :check_user_status
  
  def index    
    if params[:no_fandom]
      @fandom = nil
      tags_on_invalid = Tag.unwrangled.by_fandom(Fandom.all - Fandom.valid)
      tags_on_no_fandom = Tag.unwrangled.find_all_by_fandom_id(nil)
      @unwrangled = [tags_on_invalid + tags_on_no_fandom].flatten.uniq.compact.group_by(&:type)      
    elsif params[:fandom_id]
      @fandom = Fandom.find(params[:fandom_id]) 
      @works = @fandom.works.recent
      @unwrangled = Tag.unwrangled.by_fandom(@fandom).group_by(&:type)
    else
      @by_fandom = []
      invalid_fandoms = Tag.unwrangled.count_by_fandom(Fandom.all - Fandom.valid)
      no_fandom = Tag.unwrangled.count_by_fandom(nil)
      @by_fandom << [:no_fandom, invalid_fandoms + no_fandom]
      Fandom.valid.sort.each do |fandom|
        unwrangled = Tag.unwrangled.count_by_fandom(fandom)
        @by_fandom << [fandom, unwrangled] unless unwrangled == 0
      end
    end
    respond_to do |format|
      format.html 
      format.js
    end
  end

  def create
    if params[:fandom_id]
      fandom_id = params[:fandom_id]
    end    
    if params[:tag]
      tag_ids = params[:tag].keys
    end
    if commit = params[:commit]
      case commit
        when "Assign to Media"
          tag_ids.each { |id| Tag.find(id).update_attribute(:media_id, params[:media])}
        when "Update Fandom"
          fandom = Fandom.find(params[:fandom_id])
          if params[:media_id]
            fandom.update_attribute(:media_id, params[:media_id])
            fandom.update_attribute(:name, params[:name])
          else
            fandom.synonym = Fandom.find(params[:canonical_fandom])
          end
        when "Mark all Canonical"
          tag_ids.each do |id|
            tag = Tag.find(id)
            if tag.is_a? Freeform
              genre = Genre.find_or_create_by_name(tag.name, :canonical => true)
              tag.add_genre(genre)
            else
              tag.update_attribute(:canonical, true)
            end
          end
        when "Mark all Banned"
          tag_ids.each { |id| Tag.find(id).update_attribute(:banned, true)}
        when "Remove from Fandom"
          tag_ids.each { |id| Tag.find(id).update_attribute(:fandom_id, nil)}
        when "Mark all as Synonyms of the chosen tags"
          tag_ids.each do |id|
            tag = Tag.find(id)
            synonym = tag.class.find(params[tag.type])
            tag.synonym = synonym
          end
      end
    end
    if fandom_id
      redirect_to tag_wranglings_path(:fandom_id => fandom_id)
    else
      redirect_to tag_wranglings_path
    end
  end
end
