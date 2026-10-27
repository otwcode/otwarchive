class DownloadsController < ApplicationController

  before_action :load_work, only: :show
  before_action :check_download_posted_status, only: :show
  before_action :check_download_visibility, only: :show
  def show
    respond_to :html, :pdf, :mobi, :epub, :azw3
    download = Download.new(@work, mime_type: request.format)
    generated_download = GeneratedDownload.create!(
      kind: "work",
      arguments: { work_id: @work.id, format: download.file_type },
      filename: "#{download.file_name}.#{download.file_type}"
    )
    GeneratedDownloadJob.perform_later(generated_download)
    redirect_to generated_download_path(token: generated_download.token), status: :see_other
  end

protected

  # Set up the work and check revealed status
  # Once a format has been created, we want nginx to be able to serve
  # it directly, without going through Rails again (until the work changes).
  # This means no processing per user. Consider this the "published" version.
  # It can't contain unposted chapters, nor unrevealed creators, even
  # if the creator is the one requesting the download.
  def load_work
    unless AdminSetting.current.downloads_enabled?
      flash[:error] = ts("Sorry, downloads are currently disabled.")
      redirect_to work_path(params[:id])
      return
    end

    @work = Work.find(params[:id])
  end

  # We can't use check_visibility because this controller doesn't have access to
  # cookies on production or staging.
  def check_download_visibility
    return unless @work.hidden_by_admin || @work.in_unrevealed_collection?
    message = if @work.hidden_by_admin
                ts("Sorry, you can't download a work that has been hidden by an admin.")
              else
                ts("Sorry, you can't download an unrevealed work.")
              end
    flash[:error] = message
    redirect_to work_path(@work)
  end

  def check_download_posted_status
    return if @work.posted
    flash[:error] = ts("Sorry, you can't download a draft.")
    redirect_to work_path(@work)
  end
end
