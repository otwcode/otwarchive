require 'mime/types'

class DownloadsController < ApplicationController

  include XhtmlSplitter

  skip_before_filter :store_location, :only => :show
  before_filter :guest_downloading_off, :only => :show
  before_filter :check_visibility, :only => :show

  # once a format has been created, we want nginx to be able to serve
  # it directly, without going through rails again (until the work changes).
  # This means no processing per user. consider this the "published" version
  # It can't contain unposted chapters, nor unrevealed authors, even
  # if the author is the one requesting the download

  # named route: download_path
  # Note: only :id and :format need to be correct,
  # the other two are derived and are there for nginx's benefit
  # GET /downloads/:download_prefix/:download_authors/:id/:download_title.:format
  def show
    @work = Work.find(params[:id])
    @check_visibility_of = @work
    
    if @work.unrevealed?
      flash[:error] = ts("Sorry, you can't download an unrevealed work")
      redirect_back_or_default works_path and return
    end
    
    # check validity of type 
    download_formats = (ArchiveConfig.DOWNLOAD_FORMATS_COMMON + ArchiveConfig.DOWNLOAD_FORMATS_EXTRA) # the types (as extensions) we support
    type = ([request.url.split(".").last] & download_formats).first
    unless type.present?
      flash[:error] = ts("We don't support that format. Please try another one!")
      redirect_back_or_default work_path(@work) and return
    end

    # Generate the download
    @download_filename = @work.generate_download(type)
    
    # Make sure we were able to generate the download
    unless File.exists?(@download_filename)
      flash[:error] = ts('We were not able to render this work. Please try again in a little while or try another format.')
      redirect_back_or_default work_path(@work) and return
    end

    # Send the file with the appropriate mime type
    respond_to do |format|
      download_formats.each do |type|
        format.send(type) {send_file(@download_filename, :type => MIME::Types.type_for(@download_filename).first)}
      end
    end
  end

protected

  def guest_downloading_off
    if !logged_in? && @admin_settings.guest_downloading_off?
      redirect_to login_path(:high_load => true)
    end
  end

end
