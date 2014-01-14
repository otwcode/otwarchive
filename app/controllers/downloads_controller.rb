require 'iconv'

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

    Rails.logger.debug "Work basename: #{@work.download_basename}"
    FileUtils.mkdir_p @work.download_dir
    @chapters = @work.chapters.order('position ASC').where(:posted => true)
    create_work_html

    respond_to do |format|
      format.html {download_html}
      format.pdf {download_pdf}
      # mobipocket for kindle
      format.mobi {download_mobi}
      # epub for ibooks
      format.epub {download_epub}
    end
  end

protected

  def download_html
    create_work_html

    # send as HTML
    send_file("#{@work.download_basename}.html", :type => "text/html")
  end

  def download_pdf
    create_work_html

    # convert to PDF
    # title needs to be escaped
    title = Shellwords.escape(@work.title)
    cmd = %Q{cd "#{@work.download_dir}"; wkhtmltopdf --encoding utf-8 --title #{title} "#{@work.download_title}.html" "#{@work.download_title}.pdf"}
    Rails.logger.debug cmd
    `#{cmd} 2> /dev/null`

    # send as PDF, if file exists, or flash error and redirect
    unless check_for_file("pdf")
      flash[:error] = ts('We were not able to render this work. Please try another format')
      redirect_back_or_default work_path(@work) and return
    end
    send_file("#{@work.download_basename}.pdf", :type => "application/pdf")
  end

  def download_mobi
     cmd_pre = %Q{cd "#{@work.download_dir}"; html2mobi }
     # metadata needs to be escaped for command line
     title = Shellwords.escape(@work.title)
     author = Shellwords.escape(@work.display_authors)
     cmd_post = %Q{ --mobifile "#{@work.download_title}.mobi" --title #{title} --author #{author} }

    # if only one chapter can use same file as html and pdf versions
    if @chapters.size == 1
      create_work_html

      # except mobi requires latin1 encoding
      unless File.exists?("#{@work.download_dir}/mobi.html")
        html = Iconv.conv("LATIN1//TRANSLIT//IGNORE", "UTF8",
                 File.read("#{@work.download_basename}.html")).force_encoding("ISO-8859-1")
        File.open("#{@work.download_dir}/mobi.html", 'w') {|f| f.write(html)}
      end

      # convert latin html to mobi
      cmd = cmd_pre + "mobi.html" + cmd_post
    else
      # more than one chapter
      # create a table of contents out of separate chapter files
      mobi_files = create_mobi_html
      cmd = cmd_pre + mobi_files + " --gentoc" + cmd_post
    end
    Rails.logger.debug cmd
    `#{cmd} 2> /dev/null`
    
    # send as mobi, if file exists, or flash error and redirect
    unless check_for_file("mobi")
      flash[:error] = ts('We were not able to render this work. Please try another format')
      redirect_back_or_default work_path(@work) and return
    end
    send_file("#{@work.download_basename}.mobi", :type => "application/x-mobipocket-ebook")
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
    send_file("#{@work.download_basename}.epub", :type => "application/epub+zip")
  end

  # redirect and return inside this method would only exit *this* method, not the controller action it was called from
  def check_for_file(format)
    File.exists?("#{@work.download_basename}.#{format}")
  end

  def create_work_html
    return if File.exists?("#{@work.download_basename}.html")

    # set up instance variables needed by template
    @page_title = [@work.download_title, @work.download_authors, @work.download_fandoms].join(" - ")

    # render template
    html = render_to_string(:template => "downloads/show.html", :layout => 'barebones.html')

    # write to file
    File.open("#{@work.download_basename}.html", 'w') {|f| f.write(html)}
  end

  def create_mobi_html
    return if File.exists?("#{@work.download_basename}.mobi")
    FileUtils.mkdir_p "#{@work.download_dir}/mobi"

    # the preface contains meta tag information, the title/author, work summary and work notes
    @page_title = ts("Preface")
    render_mobi_html("_download_preface", "preface")

    # each chapter may have its own byline, notes and endnotes
    @chapters.each_with_index do |chapter, index|
      @chapter = chapter
      @page_title = chapter.chapter_title
      render_mobi_html("_download_chapter", "chapter#{index+1}")
    end

    # the afterword contains the works end notes, any related works, and a link back to comment
    @page_title = ts("Afterword")
    render_mobi_html("_download_afterword", "afterword")

    chapter_file_names = 1.upto(@chapters.size).map {|i| "mobi/chapter#{i}.html"}
    ["mobi/preface.html", chapter_file_names.join(' '), "mobi/afterword.html"].join(' ')
  end

  def render_mobi_html(template, basename)
    @mobi = true
    html = render_to_string(:template => "downloads/#{template}.html", :layout => 'barebones.html')
    html = Iconv.conv("ASCII//TRANSLIT//IGNORE", "UTF8", html)
    File.open("#{@work.download_dir}/mobi/#{basename}.html", 'w') {|f| f.write(html)}
  end

  def create_epub_files
    return if File.exists?("#{@work.download_basename}.epub")
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
    preface = render_to_string(:template => "downloads/_download_preface.html", :layout => 'barebones.html')
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
        html = render_to_string(:template => "downloads/_download_chapter.html", :layout => "barebones.html")
        render_xhtml(html, "chapter#{index + 1}_#{partindex + 1}")
      end
    end

    afterword = render_to_string(:template => "downloads/_download_afterword.html", :layout => 'barebones.html')
    render_xhtml(afterword, "afterword")

    # write the OEBPS navigation files
    File.open("#{epubdir}/OEBPS/toc.ncx", 'w') {|f| f.write(render_to_string(:file => "#{Rails.root}/app/views/epub/toc.ncx"))}
    File.open("#{epubdir}/OEBPS/content.opf", 'w') {|f| f.write(render_to_string(:file => "#{Rails.root}/app/views/epub/content.opf"))}


  end

  def render_xhtml(html, filename)
    doc = Nokogiri::XML.parse(html)
    xhtml = doc.children.to_xhtml
    File.open("#{@work.download_dir}/epub/OEBPS/#{filename}.xhtml", 'w') {|f| f.write(xhtml)}
  end

  def guest_downloading_off
    if !logged_in? && @admin_settings.guest_downloading_off?
      redirect_to login_path(:high_load => true)
    end
  end

end
