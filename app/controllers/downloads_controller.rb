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

    Rails.logger.debug "Work basename: #{@work.download_basename}"
    FileUtils.mkdir_p @work.download_dir
    @chapters = @work.chapters.order('position ASC').where(:posted => true)
    create_work_html

    respond_to do |format|
      format.html {send_file("#{@work.download_basename}.html", :type => "text/html")}
      download_formats = (ArchiveConfig.DOWNLOAD_FORMATS_COMMON + ArchiveConfig.DOWNLOAD_FORMATS_EXTRA - ['html']) 
      download_formats.each do |type|
        format.send(type) {generate_download(type)}
      end
    end
  end

protected

  # get and execute conversion command, check for file's existence and send
  def generate_download(format)
    cmd = format == "pdf" ? get_pdf_command : get_calibre_command(format)
    Rails.logger.debug cmd
    `#{cmd} 2> /dev/null`
  
    unless check_for_file(format)
      flash[:error] = ts('We were not able to render this work. Please try another format')
      redirect_back_or_default work_path(@work) and return
    end
  
    # send the file with appropriate mime type
    filename = "#{@work.download_basename}.#{format}"
    send_file(filename, :type => MIME::Types.type_for(filename).first)
  end

  # We're sticking with wkhtmltopdf for PDF files since using calibre for PDF requires the use of xvfb
  def get_pdf_command
    title = Shellwords.escape(@work.title)
    cmd = %Q{cd "#{@work.download_dir}"; wkhtmltopdf --encoding utf-8 --title #{title} "#{@work.download_title}.html" "#{@work.download_title}.pdf"}
  end

  # Create the format-specific command-line call to calibre/ebook-convert
  def get_calibre_command(format)
    ### add all the metadata we can
    title = @work.title.gsub(/"/, '\"')
    authors = @work.pseuds.collect(&:name).join("&").gsub(/"/, '\"')
    summary = @work.summary.gsub(/"/, '\"')
    tags = @work.tags.collect(&:name).join(",").gsub(/"/, '\"')
    pubdate = @work.revised_at.to_date.to_s
    
    # Add info about first series if any
    series = ""
    unless @work.series.empty?
      series = %Q{--series "#{@work.series.first.title.gsub(/"/, '\"')}" --series-index "#{SerialWork.where(:work_id => @work.id, :series_id => @work.series.first.id).value_of(:position).first}"}
    end
    
    ### Format-specific options
    # Mobi: ignore margins to keep it from padding on the left
    mobi = format == "mobi" ? "--mobi-ignore-margins" : ""

    ### 
    cmd = %Q{cd "#{@work.download_dir}"; #{ArchiveConfig.EBOOK_CONVERT} "#{@work.download_title}.html" "#{@work.download_title}.#{format}" --input-encoding utf-8 --use-auto-toc --title "#{title}" --authors "#{authors}" --comments "#{summary}" --tags "#{tags}" --pubdate "#{pubdate}" #{series} #{mobi}}
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
    html = render_to_string(:template => "downloads/show", :formats => [:html], :layout => 'barebones.html')

    # write to file
    File.open("#{@work.download_basename}.html", 'w') {|f| f.write(html)}
  end

  def guest_downloading_off
    if !logged_in? && @admin_settings.guest_downloading_off?
      redirect_to login_path(:high_load => true)
    end
  end

end
