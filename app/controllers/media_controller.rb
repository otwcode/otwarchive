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
      @fandoms = medium.fandoms.canonical.by_name.paginate(:page => params[:page])
    end
  end
end
