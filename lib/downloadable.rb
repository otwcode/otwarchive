require 'open3'

module Downloadable

  def self.included(downloadable)
    downloadable.class_eval do
      after_update :remove_outdated_downloads
    end
  end
  
  # Small helper class to be enqueued that handles actually removing the download directories
  class DownloadableCleaner
    @queue = :utilities
    def self.perform(download_dir)
      FileUtils.rm_rf download_dir
    end
  end
  
  # called to get rid of old downloads folder
  # actual deletion occurs asynchronously but we need to provide the download dir immediately
  def remove_outdated_downloads
    Resque.enqueue(DownloadableCleaner, self.download_dir)
  end

  # The absolute path to the folder where downloads will be saved
  def download_dir
    "#{Rails.public_path}/#{self.download_folder}"
  end

  # The subfolder within the public path where downloads of this object will be saved
  # We spread downloads out by the first two letters of the author name(s) in order to 
  # avoid any single folder becoming too large
  def download_folder
    dl_authors = self.download_authors
    "downloads/#{dl_authors[0..1]}/#{dl_authors}/#{self.id}"
  end
  
  # make filesystem-safe
  # ascii encoding
  # squash spaces
  # strip all alphanumeric
  # truncate to 24 chars at a word boundary
  def make_filesystem_safe(string)
    string = ActiveSupport::Inflector.transliterate(string)
    string = string.encode("us-ascii", "utf-8")
    string = string.gsub(/[^[\w _-]]+/, '')
    string = string.gsub(/ +/, " ")
    string = string.strip
    string = string.truncate(24, :separator => ' ', :omission => '')
    string
  end

  # The fandoms of the work -- used in the page title for the download
  # fine if this is blank
  def download_fandoms
    string = self.fandoms.size > 3 ? ts("Multifandom") : self.fandoms.string
    string = make_filesystem_safe(string)
    return string
  end
  
  # The names of the authors -- used to generate the download folder name and page title for the download
  def download_authors
    if self.anonymous? 
      return ts("Anonymous")
    else
      # if we can make pseuds filesys safe use them, otherwise use login
      string = self.pseuds.collect {|pseud|
        name = make_filesystem_safe(pseud.name)
        name = pseud.user.login unless name.length > 2
        name
      }.join('-')
      return make_filesystem_safe(string)
    end
  end

  # The title of the work -- used in the download filename and page title
  def download_title
    string = make_filesystem_safe(self.title)
    # provide fallback if the string is too short
    string = "Work #{self.id}" if string.length < 3 
    return string
  end
  
  # The absolute path to the download file minus the filetype suffix 
  def download_basename
    "#{self.download_dir}/#{self.download_title}"
  end

  # Generate the download and return the filename
  def generate_download(type)
    # prerequisite for any type
    generate_html_download 
    
    unless type == "html"
      generate_ebook_download(type)
    end
    
    return "#{self.download_basename}.#{type}"
  end

  # Write the HTML version
  def generate_html_download
    html_filename = "#{self.download_basename}.html"
    return if File.exists?(html_filename)
    
    # Create the directory
    FileUtils.mkdir_p self.download_dir      

    # Only handles Work currently
    if self.is_a?(Work)
      # set up instance variables needed by template
      page_title = [self.download_title, self.download_authors, self.download_fandoms].join(" - ")
      chapters = self.chapters.order('position ASC').where(:posted => true)


      # sneaking around MVC division, but the rendering of downloads belongs in this module IMO and not
      # in the controller
      # set this to handle host lookups
      Otwarchive::Application.routes.default_url_options = { :host => ArchiveConfig.APP_HOST }
      view = ActionView::Base.new(ActionController::Base.view_paths, {})
      view.class_eval do
        include Rails.application.routes.url_helpers
        include ApplicationHelper
        include TagsHelper
        def current_user
          nil
        end
      end      
      @html = view.render(:template => "/downloads/show", :formats => [:html], :layout => '/layouts/barebones.html', :locals => {:@work => self, :@page_title => page_title, :@chapters => chapters})
    end
    # reset back so tests don't get confused
    Otwarchive::Application.routes.default_url_options = {}    
        
    # write to file
    File.open(html_filename, 'w:UTF-8') {|f| f.write(@html)}
  end

  # transform HTML version into ebook version, check for file's existence and send
  def generate_ebook_download(format)
    cmd = (format == "pdf" ? get_pdf_command : get_calibre_command(format))

    # Make sure the command is sanitary, and use popen3 in order to
    # capture and discard the stdin/out info
    # See http://stackoverflow.com/a/5970819/469544 for details
    exit_status = nil
    Open3.popen3(*cmd) {|stdin, stdout, stderr, wait_thread| exit_status = wait_thread.value}
    unless exit_status
      Rails.logger.debug "Download generation failed: " + cmd.to_s
    end
  end

  # We're sticking with wkhtmltopdf for PDF files since using calibre for PDF requires the use of xvfb
  def get_pdf_command
    pdf_convert_command = ['wkhtmltopdf', '--encoding', 'utf-8', 
      '--title', self.title,
      "#{self.download_basename}.html", "#{self.download_basename}.pdf"]
  end

  # Create the format-specific command-line call to calibre/ebook-convert
  def get_calibre_command(format)
    ### add all the metadata we can
    authors = self.pseuds.collect(&:name).join("&")
    tags = self.tags.collect(&:name).join(",")
    pubdate = self.revised_at.to_date.to_s

    # Add info about first series if any
    series = []
    unless self.series.empty?
      series = ['--series', self.series.first.title, '--series-index', SerialWork.where(:work_id => self.id, :series_id => self.series.first.id).value_of(:position).first]
    end

    ### Format-specific options
    # Mobi: ignore margins to keep it from padding on the left
    mobi = format == "mobi" ? ['--mobi-ignore-margins'] : []

    ### 
    ebook_convert_command = [ArchiveConfig.EBOOK_CONVERT, "#{self.download_basename}.html", "#{self.download_basename}.#{format}", '--input-encoding', 'utf-8', '--use-auto-toc', 
      '--title', self.title, '--authors', authors, '--comments', self.summary,
      '--tags', tags, '--pubdate', pubdate] + series + mobi
  end

end