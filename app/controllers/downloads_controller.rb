class DownloadsController < ApplicationController

  include XhtmlSplitter

  skip_before_action :store_location, only: :show
  before_action :guest_downloading_off, only: :show
  before_action :check_visibility, only: :show

  # named route: download_path
  # Note: only :id and :format need to be correct,
  # the other two are derived and are there for nginx's benefit
  # GET /downloads/:download_prefix/:download_authors/:id/:download_title.:format
  def show
    @work = Work.find(params[:id])
    @check_visibility_of = @work

    if @work.unrevealed?
      flash[:error] = ts("Sorry, you can't download an unrevealed work")
      redirect_back_or_default works_path
      return
    end

    unless @admin_settings.downloads_enabled?
      flash[:error] = ts("Sorry, downloads are currently disabled.")
      redirect_back_or_default works_path
      return
    end

    FileUtils.mkdir_p @work.download_dir
    @chapters = @work.chapters.order('position ASC').where(posted: true)
    create_work_html

    respond_to do |format|
      format.html do
        download_html
        return
      end
      format.pdf { download_pdf }
      # mobipocket for kindle
      format.mobi { download_mobi }
      # epub for ibooks
      format.epub { download_epub }
    end
    @work.remove_outdated_downloads
  end

protected

  def download_html
    data = create_work_html_string
    # send as HTML
    send_data data, filename: "#{@work.download_title}.html", type: "text/html"
  end

  def send_file_sync(file_type, mime_type)
    # send file synchronously so we don't delete it before we have finsihed sending it.
    File.open("#{@work.download_basename}.#{file_type}", 'r') do |f|
      send_data f.read, filename: "#{@work.download_title}.#{file_type}", type: mime_type
    end
  end

  def download_pdf
    create_work_html

    # convert to PDF
    # title needs to be escaped
    title = Shellwords.escape(@work.title)
    cmd = %Q{cd "#{@work.download_dir}"; wkhtmltopdf --encoding utf-8 --disable-javascript --title #{title} "#{@work.download_title}.html" "#{@work.download_title}.pdf"}
    Rails.logger.debug cmd
    `#{cmd} 2> /dev/null`

    # send as PDF, if file exists, or flash error and redirect
    unless check_for_file("pdf")
      flash[:error] = ts('We were not able to render this work. Please try another format')
      redirect_back_or_default work_path(@work) and return
    end
    send_file_sync("pdf", "application/pdf")
  end

  def download_mobi
    cmd_pre = %Q{cd "#{@work.download_dir}"; html2mobi }
    # metadata needs to be escaped for command line
    title = Shellwords.escape(@work.title)
    author = Shellwords.escape(@work.display_authors)
    cmd_post = %Q{ --mobifile "#{@work.download_title}.mobi" --title #{title} --author #{author} }

    # more than one chapter
    # create a table of contents out of separate chapter files
    mobi_files = create_mobi_html
    cmd = cmd_pre + mobi_files + cmd_post
    if @chapters.length > 1
      cmd << " --gentoc"
    end
    Rails.logger.debug cmd
    `#{cmd} 2> /dev/null`

    # send as mobi, if file exists, or flash error and redirect
    unless check_for_file("mobi")
      flash[:error] = ts('We were not able to render this work. Please try another format')
      redirect_back_or_default work_path(@work) and return
    end
    send_file_sync("mobi", "aapplication/x-mobipocket-ebook")
  end

  def download_epub
    create_epub_files

    # stuff contents of epub directory into a zip file named with
    # .epub extension
    #
    # note: we have to zip this up in this particular order because
    # "mimetype" must be the first item in the zipfile and mustn't be
    # compressed
    cmd = %Q{cd "#{@work.download_dir}/epub"; zip -0 "#{@work.download_basename}.epub" mimetype; zip -r "#{@work.download_basename}.epub" META-INF OEBPS}
    Rails.logger.debug cmd
   `#{cmd} 2> /dev/null`

    # send as epub, if file exists, or flash error and redirect
    unless check_for_file("epub")
      flash[:error] = ts('We were not able to render this work. Please try another format')
      redirect_back_or_default work_path(@work) and return
    end
    send_file_sync("epub", "application/epub+zip")
  end

  # redirect and return inside this method would only exit *this* method, not the controller action it was called from
  def check_for_file(format)
    File.exist?("#{@work.download_basename}.#{format}")
  end

  def create_work_html_string
    @page_title = [@work.download_title, @work.download_authors, @work.download_fandoms].join(" - ")
    render_to_string(template: "downloads/show.html", layout: 'barebones.html')
  end

  def create_work_html
    return if File.exist?("#{@work.download_basename}.html")
    # write to file
    File.open("#{@work.download_basename}.html", 'w') { |f| f.write(create_work_html_string) }
  end

  def create_mobi_html
    FileUtils.mkdir_p "#{@work.download_dir}/mobi"

    # the preface contains meta tag information, the title/author, work summary and work notes
    @page_title = ts("Preface")
    render_mobi_html("_download_preface", "preface")

    # each chapter may have its own byline, notes and endnotes
    @chapters.each_with_index do |chapter, index|
      @chapter = chapter
      @page_title = chapter.chapter_title
      render_mobi_html("_download_chapter", "chapter#{index + 1}")
    end

    # the afterword contains the works end notes, any related works, and a link back to comment
    @page_title = ts("Afterword")
    render_mobi_html("_download_afterword", "afterword")

    chapter_file_names = 1.upto(@chapters.size).map { |i| "mobi/chapter#{i}.html" }
    ["mobi/preface.html", chapter_file_names.join(' '), "mobi/afterword.html"].join(' ')
  end

  def render_mobi_html(template, basename)
    @mobi = true
    html = render_to_string(template: "downloads/#{template}.html", layout: 'barebones.html')
    html = html.to_ascii
    File.open("#{@work.download_dir}/mobi/#{basename}.html", 'w') { |f| f.write(html) }
  end

  def create_epub_files
    return if File.exist?("#{@work.download_basename}.epub")
    # Manually building an epub file here
    # See http://www.jedisaber.com/eBooks/tutorial.asp for details
    epubdir = "#{@work.download_dir}/epub"
    FileUtils.mkdir_p epubdir

    # copy mimetype and container files which don't need processing
    FileUtils.cp("#{Rails.root}/app/views/epub/mimetype", epubdir)
    FileUtils.mkdir_p "#{epubdir}/META-INF"
    FileUtils.cp("#{Rails.root}/app/views/epub/container.xml", "#{epubdir}/META-INF")

    # write the OEBPS content files
    FileUtils.mkdir_p "#{epubdir}/OEBPS"
    preface = render_to_string(template: "downloads/_download_preface.html", layout: 'barebones.html')
    render_xhtml(preface, "preface")

    @parts = []
    @chapters.each_with_index do |chapter, index|
      @chapter = chapter

      # split chapters into multiple parts if they are too big
      @parts << split_xhtml(sanitize_field(@chapter, :content))
      @parts[-1].each_with_index do |part, partindex|
        @content = part
        # we only need the chapter meta/endnotes info if it's a
        # multichaptered work and if we are displaying the first/last
        # part of a chapter
        @suppress_chapter_meta = @chapters.size == 1 || partindex > 0
        @suppress_chapter_endnotes = @chapters.size == 1 || partindex < @parts[-1].size
        html = render_to_string(template: "downloads/_download_chapter.html", layout: "barebones.html")
        render_xhtml(html, "chapter#{index + 1}_#{partindex + 1}")
      end
    end

    afterword = render_to_string(template: "downloads/_download_afterword.html", layout: 'barebones.html')
    render_xhtml(afterword, "afterword")

    # write the OEBPS navigation files
    File.open("#{epubdir}/OEBPS/toc.ncx", 'w') { |f| f.write(render_to_string(file: "#{Rails.root}/app/views/epub/toc.ncx", layout: false)) }
    File.open("#{epubdir}/OEBPS/content.opf", 'w') { |f| f.write(render_to_string(file: "#{Rails.root}/app/views/epub/content.opf", layout: false)) }
  end

  def render_xhtml(html, filename)
    doc = Nokogiri::XML.parse(html)
    xhtml = doc.children.to_xhtml
    File.open("#{@work.download_dir}/epub/OEBPS/#{filename}.xhtml", 'w') { |f| f.write(xhtml) }
  end

  def guest_downloading_off
    if !logged_in? && @admin_settings.guest_downloading_off?
      redirect_to login_path(high_load: true)
    end
  end

end

