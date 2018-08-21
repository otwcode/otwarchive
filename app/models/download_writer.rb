require 'open3'

class DownloadWriter
  attr_reader :download, :work, :html_download

  def initialize(download)
    @download = download
    @work = download.work
    @html_download = Download.new(work, format: "html")
  end

  def write
    # Create the directory
    FileUtils.mkdir_p download.dir
    generate_html_download
    generate_ebook_download unless download.file_type == "html"
    download
  end

  private

  # Write the HTML version
  def generate_html_download
    return if html_download.exists?

    renderer = ApplicationController.renderer.new(
      http_host: ArchiveConfig.APP_HOST
    )
    @html = renderer.render(
      template: 'downloads/show',
      layout: 'barebones',
      assigns: {
        work: work,
        page_title: download.page_title,
        chapters: download.chapters
      }
    )
        
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
    Open3.popen3(*cmd) { |_stdin, _stdout, _stderr, wait_thread| exit_status = wait_thread.value }
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
      '--disable-javascript',
      '--title', download.file_name,
      html_download.file_path, download.file_path
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
    # epub: don't generate a cover image
    epub = download.file_type == "epub" ? ['--no-default-epub-cover'] : []

    [
      'ebook-convert',
      html_download.file_path,
      download.file_path,
      '--input-encoding', 'utf-8',
      '--use-auto-toc',
      '--title', meta[:title],
      '--title-sort', meta[:sortable_title],
      '--authors', meta[:authors],
      '--author-sort', meta[:sortable_authors],
      '--comments', meta[:summary],
      '--tags', meta[:tags],
      '--pubdate', meta[:pubdate],
      '--publisher', ArchiveConfig.APP_NAME,
      '--language', meta[:language],
      '--extra-css', '/stylesheets/ebooks.css',
      # XPaths for detecting chapters are overly specific to make sure we don't grab
      # anything inputted by the user. First path is for single-chapter works,
      # second for multi-chapter, and third for the preface and afterword
      '--chapter', "//h:body/h:div[@id='chapters']/h:h2[@class='toc-heading'] | //h:body/h:div[@id='chapters']/h:div[@class='meta group']/h:h2[@class='heading'] | //h:body/h:div[@id='preface' or @id='afterword']/h:h2[@class='toc-heading']"
    ] + series + epub
  end

  # A hash of the work data calibre needs
  def meta
    return @metadata if @metadata
    @metadata = {
      title:             work.title,
      sortable_title:    work.sorted_title,
      authors:           work.pseuds.pluck(:name).join("&"),
      sortable_authors:  work.authors_to_sort_on,
      # We add "Fanworks" because iBooks uses the first tag as the category and
      # it would otherwise be the work's rating, which is weird
      tags:              "Fanworks, " + work.tags.pluck(:name).join(","),
      pubdate:           work.revised_at.to_date.to_s,
      summary:           work.summary,
      language:          work.language.short
    }
    if work.series.exists?
      series = work.series.first
      @metadata.merge(
        series_title: series.title,
        series_position: series.position_of(work).to_s
      )
    end
    @metadata
  end
end
