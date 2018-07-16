require 'open3'

class DownloadWriter

  include Rails.application.routes.url_helpers
  include ApplicationHelper
  include TagsHelper

  attr_reader :download, :work, :html_download

  def initialize(download)
    @download = download
    @work = download.work
    @html_download = Download.new(work, "text/html")
  end

  def write
    # Create the directory
    FileUtils.mkdir_p download.dir
    generate_html_download
    generate_ebook_download unless download.file_type == "html"
    return download.file_name
  end

  private

  # Write the HTML version
  def generate_html_download
    return if html_download.exists?
    # sneaking around MVC division, but the rendering of downloads belongs in a module IMO and not
    # in the controller
    # set this to handle host lookups
    Otwarchive::Application.routes.default_url_options = { host: ArchiveConfig.APP_HOST }
    @html = download_view.render(
      template: "/downloads/show",
      formats: [:html],
      layout: '/layouts/barebones.html',
      locals: {
        :@work => work,
        :@page_title => download.page_title,
        :@chapters => download.chapters
      }
    )
    # reset back so tests don't get confused
    Otwarchive::Application.routes.default_url_options = {}    
        
    # write to file
    File.open(html_download.file_path, 'w:UTF-8') { |f| f.write(@html) }
  end

  # transform HTML version into ebook version
  def generate_ebook_download
    return unless %w(mobi epub pdf).include?(download.file_type)
    return if download.exists?

    cmd = get_command

    # Make sure the command is sanitary, and use popen3 in order to
    # capture and discard the stdin/out info
    # See http://stackoverflow.com/a/5970819/469544 for details
    exit_status = nil
    Open3.popen3(*cmd) { |stdin, stdout, stderr, wait_thread| exit_status = wait_thread.value }
    unless exit_status
      Rails.logger.debug "Download generation failed: " + cmd.to_s
    end
  end

  # Get the version of the command we need to execute
  def get_command
    download.file_type == "pdf" ? get_pdf_command : get_calibre_command
  end

  # We're sticking with wkhtmltopdf for PDF files since using calibre for PDF requires the use of xvfb
  def get_pdf_command
    [
      'wkhtmltopdf',
      '--encoding', 'utf-8', 
      '--title', work.title,
      "#{download.file_name}.html", "#{download.file_name}.pdf"
    ]
  end

  # Create the format-specific command-line call to calibre/ebook-convert
  def get_calibre_command
    # Add info about first series if any
    series = []
    if meta[:series_title].present?
      series = ['--series', meta[:series_title], '--series-index', meta[:series_position]]
    end

    ### Format-specific options
    # Mobi: ignore margins to keep it from padding on the left
    mobi = download.file_type == "mobi" ? ['--mobi-ignore-margins'] : []

    ### 
    ebook_convert_command = [
      'ebook-convert',
      "#{download.file_name}.html",
      "#{download.file_name}.#{download.file_type}",
      '--input-encoding', 'utf-8',
      '--use-auto-toc',
      '--title', meta[:title],
      '--authors', meta[:authors],
      '--comments', meta[:summary],
      '--tags', meta[:tags],
      '--pubdate', meta[:pubdate]
    ] + series + mobi
  end

  # Set up a Rails view so we can render standard view files
  def download_view
    @view = ActionView::Base.new(ActionController::Base.view_paths, {})
    @view.class_eval do
      def current_user; nil; end
    end
    @view
  end

  # A hash of the work data calibre needs
  def meta
    return @metadata if @metadata
    @metadata = {
      title:    work.title,
      authors:  work.pseuds.pluck(:name).join("&"),
      tags:     work.tags.pluck(:name).join(","),
      pubdate:  work.revised_at.to_date.to_s,
      summary:  work.summary
    }
    if work.series.exist?
      series = work.series.first
      @metadata.merge(
        series_title: series.title,
        series_position: series.position_of(work).to_s
      )
    end
    @metadata
  end
end
