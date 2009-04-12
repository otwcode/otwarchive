class MediaController < ApplicationController

  def index
    @fandom_listing = Fandom.canonical.group_by(&:media).sort_by{|array| array[1].size}.reverse + [[nil,Fandom.no_parent]]
  end

  def show
    if params[:id] == "0"
      @medium_name = "Uncategorized Fandoms"
      @fandoms = Fandom.no_parent.by_name.paginate(:page => params[:page])
    else
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
end
