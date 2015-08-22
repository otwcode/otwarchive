require 'mime/types'

class DownloadsController < ApplicationController

  skip_before_filter :store_location, :only => :show
  before_filter :load_work, :only => :show
  before_filter :check_visibility, :only => :show
  before_filter :check_type, :only => :show
  before_filter :guest_downloading_off, :only => :show

  # named route: download_path
  # Note: only :id and :format need to be correct,
  # the others are derived from a hash of the id and are there to spread the downloads around
  # GET /downloads/:download_slice1/:download_slice2/:download_slice3/:download_slice4/:download_slice5/:id/:download_title.:format
  def show
    @work = Work.find(params[:id])
    @check_visibility_of = @work

    if @work.unrevealed?
      flash[:error] = ts("Sorry, you can't download an unrevealed work")
      redirect_back_or_default works_path and return
    end

    # Generate the download
    # the dont_generate_download option is here to facilitate testing for the error message
    @download_filename = @work.generate_download(@type) unless params[:dont_generate_download].present?
  
    # Make sure we were able to generate the download
    unless @download_filename.present? && File.exists?(@download_filename)
      flash[:error] = ts('We were not able to render this work. Please try again in a little while or try another format.')
      redirect_to work_path(@work)
      return
    end    
    
    # Send the file with the appropriate mime type
    respond_to do |format|
      format.send(@type) {send_file(@download_filename, :type => MIME::Types.type_for(@download_filename).first)}
    end
  end


  ##################
  # before_filters
  ##################

  protected

  # at times of high load prevent guests from generating new downloads
  def guest_downloading_off
    if !logged_in? && @admin_settings.guest_downloading_off?
      redirect_to login_path(:high_load => true)
    end
  end

  # Set up the work and check revealed status
  # once a format has been created, we want nginx to be able to serve
  # it directly, without going through rails again (until the work changes).
  # This means no processing per user. consider this the "published" version
  # It can't contain unposted chapters, nor unrevealed authors, even
  # if the author is the one requesting the download
  def load_work
    @work = Work.find(params[:id])
    
    if @work.in_unrevealed_collection?
      flash[:error] = ts("Sorry, you can't download an unrevealed work.")
      redirect_to work_path(@work)
      return
    end

    # set this for checking visibility
    @check_visibility_of = @work
  end
  
  # make sure we support the type of file being requested 
  # (in case someone manually types in a different extension)
  def check_type
    # I do this complicated split here to get the requested file extension while allowing parameters
    extension = request.url.split(".").last.split("?").first
    @download_formats = (ArchiveConfig.DOWNLOAD_FORMATS_COMMON + ArchiveConfig.DOWNLOAD_FORMATS_EXTRA) # the types (as extensions) we support
    @type = ([extension] & @download_formats).first
    unless @type.present?
      flash[:error] = ts("We don't support that format. Please try another one!")
      redirect_to work_path(@work)
      return
    end
  end
  
end

