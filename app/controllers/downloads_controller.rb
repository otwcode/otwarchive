class DownloadsController < ApplicationController
  skip_before_action :store_location, only: :show
  before_action :load_target, only: :show
  before_action :check_download_posted_status, only: :show
  before_action :check_download_visibility, only: :show
  around_action :remove_downloads, only: :show

  def show
    respond_to :html, :pdf, :mobi, :epub, :azw3
    @download = Download.new(@target, mime_type: request.format)
    @download.generate

    # Make sure we were able to generate the download.
    unless @download.exists?
      flash[:error] = t(".render_failed",
                        "We were not able to render this %{type}. Please try again in a little while or try another format.",
                        type: params[:type])
      redirect_to @target
      return
    end

    # Send file synchronously so we don't delete it before we have finished
    # sending it
    File.open(@download.file_path, "r") do |f|
      send_data f.read, filename: "#{@download.file_name}.#{@download.file_type}", type: @download.mime_type
    end
  end

  protected

  # Set up the target and check revealed status
  # Once a format has been created, we want nginx to be able to serve
  # it directly, without going through Rails again (until the target changes).
  # This means no processing per user. Consider this the "published" version.
  # It can't contain unposted chapters, nor unrevealed creators, even
  # if the creator is the one requesting the download.
  def load_target
    unless @admin_settings.downloads_enabled?
      flash[:error] = ts("Sorry, downloads are currently disabled.")
      redirect_back_or_default root_path
      return
    end

    unless %w[series work].include?(params[:type])
      flash[:error] = t(".unknown_type",
                        "Unknown download type '%{download_type}'.",
                        download_type: params[:type])
      redirect_back_or_default root_path
      return
    end

    @target = if params[:type] == "series"
                Series.find(params[:id])
              else
                Work.find(params[:id])
              end
  end

  # We're currently just writing everything to tmp and feeding them through
  # nginx so we don't want to keep the files around.
  def remove_downloads
    yield
  ensure
    @download.remove
  end

  # We can't use check_visibility because this controller doesn't have access to
  # cookies on production or staging.
  def check_download_visibility
    return unless @target.hidden_by_admin ||
                  (@target.is_a?(Work) && @target.in_unrevealed_collection?)

    message = if @target.hidden_by_admin
                t(".admin_hidden",
                  "Sorry, you can't download a %{type} that has been hidden by an admin.",
                  type: params[:type])
              else
                ts("Sorry, you can't download an unrevealed work.")
              end

    flash[:error] = message
    redirect_to @target
  end

  def check_download_posted_status
    return if @target.posted

    flash[:error] = ts("Sorry, you can't download a draft.")
    redirect_to @target
  end
end
