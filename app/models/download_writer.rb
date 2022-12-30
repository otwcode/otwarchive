require "open3"

class DownloadWriter
  attr_reader :download, :target

  def initialize(download)
    @download = download
    @target = download.target
  end

  def write
    generate_html_download
    generate_ebook_download unless download.file_type == "html"
    download
  end

  def generate_html
    renderer = ApplicationController.renderer.new(
      http_host: ArchiveConfig.APP_HOST
    )
    renderer.render(
      template: "downloads/show",
      layout: "barebones",
      assigns: {
        downloadable: target,
        page_title: download.page_title
      }
    )
  end

  private

  # Write the HTML version to file
  def generate_html_download
    return if download.exists?

    File.open(download.html_file_path, "w:UTF-8") { |f| f.write(generate_html) }
  end

  # transform HTML version into ebook version
  def generate_ebook_download
    return unless %w[azw3 epub mobi pdf].include?(download.file_type)
    return if download.exists?

    # Make sure the command is sanitary, and use popen3 in order to
    # capture and discard the stdin/out info
    # See http://stackoverflow.com/a/5970819/469544 for details
    commands.each do |cmd|
      exit_status = nil
      Open3.popen3(*cmd) { |_stdin, _stdout, _stderr, wait_thread| exit_status = wait_thread.value }
      Rails.logger.debug "Download generation failed: " + cmd.to_s unless exit_status
    end
  end

  # Get the version of the command we need to execute
  def commands
    return [pdf_command] if download.file_type == "pdf"

    [web2disk_command, zip_command, calibre_command]
  end

  # We're sticking with wkhtmltopdf for PDF files since using calibre for PDF requires the use of xvfb
  def pdf_command
    [
      "wkhtmltopdf",
      "--encoding", "utf-8",
      "--disable-javascript",
      "--disable-smart-shrinking",
      "--log-level", "none",
      "--title", download.file_name,
      download.html_file_path, download.file_path
    ]
  end

  # Create the format-specific command-line call to calibre/ebook-convert
  def calibre_command
    # Add info about first series if any
    series = []
    series = ["--series", meta[:series_title], "--series-index", meta[:series_position]] if meta[:series_title].present?

    ### Format-specific options
    # epub: don't generate a cover image
    epub = download.file_type == "epub" ? ["--no-default-epub-cover"] : []

    [
      "ebook-convert",
      download.zip_path,
      download.file_path,
      "--input-encoding", "utf-8",
      # Prevent it from turning links to endnotes into entries for the table of
      # contents on works with fewer than the specified number of chapters.
      "--toc-threshold", "0",
      "--use-auto-toc",
      "--title", meta[:title],
      "--title-sort", meta[:sortable_title],
      "--authors", meta[:authors],
      "--author-sort", meta[:sortable_authors],
      "--comments", meta[:summary],
      "--tags", meta[:tags],
      "--pubdate", meta[:pubdate],
      "--publisher", ArchiveConfig.APP_NAME,
      "--language", meta[:language],
      "--extra-css", Rails.public_path.join("stylesheets/ebooks.css").to_s,
      # XPaths for detecting chapters are overly specific to make sure we don't grab
      # anything inputted by the user. First path is for single-chapter works,
      # second for multi-chapter, and third for the preface and afterword
      "--chapter", "//h:body/h:div[@id='chapters']/h:h2[@class='toc-heading'] | //h:body/h:div[@id='chapters']/h:div[@class='meta group']/h:h2[@class='heading'] | //h:body/h:div[@id='work-preface' or @id='afterword']/h:h2[@class='toc-heading']",
      "--level1-toc", "//h:body/h:div[@id='series-preface']/h:h1[@class='toc-heading'] | //h:body/h:div[@id='work-preface']/h:p[@class='message']/h:b[@class='work-title']",
      "--level2-toc", "//h:body/h:div[@id='chapters']/h:h2[@class='toc-heading'] | //h:body/h:div[@id='chapters']/h:div[@class='meta group']/h:h2[@class='heading']"
    ] + series + epub
  end

  # Grab the HTML file and any images and put them in --base-dir.
  # --max-recursions 0 prevents it from grabbing all the linked pages.
  # --dont-download-stylesheets isn't strictly necessary for us but avoids
  # creating an empty stylesheets directory.
  def web2disk_command
    [
      "web2disk",
      "--base-dir", download.assets_path,
      "--max-recursions", "0",
      "--dont-download-stylesheets",
      "file://#{download.html_file_path}"
    ]
  end

  # Zip the directory containing the HTML file and images.
  def zip_command
    [
      "zip",
      "-r",
      download.zip_path,
      download.assets_path
    ]
  end

  # A hash of the target data calibre needs
  def meta
    return @metadata if @metadata

    tags = target.is_a?(Series) ? target.work_tags.distinct : target.tags
    @metadata = {
      title: target.title,
      sortable_title: target.sorted_title,
      # Using ampersands as instructed by Calibre's ebook-convert documentation
      # hides all but the first author name in Books (formerly iBooks). The
      # other authors cannot be used for searching or sorting. Using commas
      # just means Calibre's GUI treats it as one name, e.g. "testy, testy2" is
      # like "Fangirl, Suzy Q", for searching and sorting.
      authors: download.authors,
      sortable_authors: target.authors_to_sort_on,
      # We add "Fanworks" because Books uses the first tag as the category and
      # it would otherwise be the work's rating, which is weird.
      tags: "Fanworks, " + tags.pluck(:name).join(", "),
      pubdate: target.revised_at.to_date.to_s,
      summary: target.summary.to_s,
      language: target.language.short
    }
    if target.is_a?(Work) && target.series.exists?
      series = target.series.first
      @metadata[:series_title] = series.title
      @metadata[:series_position] = series.position_of(target).to_s
    end
    @metadata
  end
end
