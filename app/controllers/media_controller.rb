class MediaController < ApplicationController

  def index
    @media = Media.all - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
    @fandom_listing = {}
    @media.each do |medium|
      if medium == Media.uncategorized
        @fandom_listing[medium] = medium.fandoms.find(:all, :order => 'created_at DESC', :limit => 5)
      else
        @fandom_listing[medium] = (logged_in? || logged_in_as_admin?) ? medium.fandoms.unhidden_top(5) : medium.fandoms.public_top(5)
      end
    end
  end

  def show
    medium = Media.find_by_name(params[:id])
    @medium_name = medium.name
    @media_alphabet = medium.fandoms.canonical.select{|f| f.visible_synonyms_works_count > 0}.collect {|fandom| fandom.name[0,1].upcase}.uniq.sort
    if params[:letter] && params[:letter].is_a?(String)
      letter = params[:letter][0,1]
    else
      letter = @media_alphabet[0]
    end
    @fandoms = medium.fandoms.canonical.starting_with(letter).select{|f| f.visible_synonyms_works_count > 0} #.paginate(:page => params[:page])
  end
end
