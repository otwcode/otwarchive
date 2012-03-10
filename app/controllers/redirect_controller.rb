class RedirectController < ApplicationController
  before_filter :get_url_to_look_for
  
  def get_url_to_look_for
    @original_url = params[:original_url] || ""
    @minimal_url = @original_url
    # strip it down to the most basic URL
    @minimal_url.gsub!(/\?.*$/, "")
    @minimal_url.gsub!(/\#.*$/, "")
  end
  
  def do_redirect
    if @original_url.blank?
      flash[:error] = t('redirect.none', :default => "What url did you want to look up?")
    else
      @work = Work.find_by_imported_from_url(@original_url) || Work.find(:first, :conditions => ["imported_from_url LIKE :url", {:url => "%#{@minimal_url}%"}])
      if @work
        redirect_to work_path(@work) and return
      else 
        flash[:error] = t('redirect.failed', :default => "We could not find a work imported from that url in the Archive of Our Own, sorry! Try another url?")
      end
    end
    redirect_to :action => :index
  end 
  
  def index
    if !@original_url.blank?
      redirect_to :action => :do_redirect, :original_url => @original_url and return
    end
  end
  
end
