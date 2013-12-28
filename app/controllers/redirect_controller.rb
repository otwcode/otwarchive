class RedirectController < ApplicationController
  before_filter :get_url_to_look_for

  def index
    do_redirect
  end

  def get_url_to_look_for
    @original_url = params[:original_url] || ""

    # strip it down to the most basic URL
    @minimal_url = @original_url.gsub(/\?.*$/, "").gsub(/\#.*$/, "")

    # remove www if present
    @no_www_url = @original_url.gsub(/http:\/\/www\./, "http://")

    # add www in case it is needed
    @with_www_url = @original_url.gsub(/http:\/\//, "http://www.")

    # get encoded and unencoded versions
    @encoded_url = URI.encode(@minimal_url)
    @decoded_url = URI.decode(@minimal_url)
  end

  def do_redirect
    if @original_url.blank?
      flash[:error] = ts("What url did you want to look up?")
    else
      urls = [@original_url, @minimal_url, @no_www_url, @with_www_url, @encoded_url, @decoded_url]
      @work = Work.where(:imported_from_url => @original_url).first ||
          Work.where(:imported_from_url => [@minimal_url, @no_www_url, @with_www_url, @encoded_url, @decoded_url]).first ||
          Work.where("imported_from_url LIKE ? OR imported_from_url LIKE ?", "%#{@encoded_url}%", "%#{@decoded_url}%").first
      if @work
        flash[:notice] = ts("You have been redirected here from #{@original_url}. Please update the original link if possible!")
        redirect_to work_path(@work) and return
      else
        flash[:error] = ts("We could not find a work imported from that url in the Archive of Our Own, sorry! Try another url?")
        if Rails.env.development?
          flash[:error] += " We checked all of the following URLs: #{urls.to_sentence}"
        end
      end
    end
    redirect_to redirect_path
  end

  def show
    if !@original_url.blank?
      redirect_to :action => :do_redirect, :original_url => @original_url and return
    end
  end

end
