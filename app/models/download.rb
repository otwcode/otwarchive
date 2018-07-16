class Download

  def self.generate(work, options = {})
    new(work, options).generate
  end

  def self.remove(work)
    new(work).remove
  end

  attr_reader :work, :file_type

  def initialize(work, options = {})
    @work = work
    @file_type = set_file_type(options.slice(:mime_type, :format))
  end

  def generate
    DownloadWriter.new(self).write
    self
  end

  def exists?
    File.exists?(file_path)
  end

  def remove
    FileUtils.rm_rf(dir)
  end

  # Given either a file extension or a mime type, figure out
  # what format we're generating
  # Defaults to html
  def set_file_type(options)
    if options[:mime_type]
      ext = MimeMagic.new(options[:mime_type].to_s).subtype
      ext == "x-mobipocket-ebook" ? "mobi" : ext
    elsif %w(html pdf mobi epub).include?(options[:format].to_s)
      options[:format].to_s
    else
      "html"
    end
  end

  def file_name
    clean(work.title) || "Work #{work.id}"
  end

  def public_path
    "/downloads/#{work.id}/#{file_name}.#{file_type}"
  end

  def file_path
    "#{dir}/#{file_name}.#{file_type}"
  end

  def dir
    "/tmp/#{work.id}"
  end

  def fandoms
    string = work.fandoms.size > 3 ? ts("Multifandom") : work.fandoms.string
    clean(string)
  end

  def authors
    author_names.join(', ').to_ascii
  end

  def author_names
    work.anonymous? ? [ts("Anonymous")] : work.pseuds.sort.map(&:name)
  end

  # need the next two to be filesystem safe and not overly long
  def file_authors
    clean(author_names.join('-'))
  end

  def page_title
    [file_name, file_authors, fandoms].join(" - ")
  end
  
  def chapters
    work.chapters.order('position ASC').where(:posted => true)
  end


  private

  # make filesystem-safe
  # ascii encoding
  # squash spaces
  # strip all alphanumeric
  # truncate to 24 chars at a word boundary
  def clean(string)
    # get rid of any HTML entities to avoid things like "amp" showing up in titles
    string = string.gsub(/\&(\w+)\;/, '')
    string = ActiveSupport::Inflector.transliterate(string)
    string = string.encode("us-ascii", "utf-8")
    string = string.gsub(/[^[\w _-]]+/, '')
    string = string.gsub(/ +/, " ")
    string = string.strip
    string = string.truncate(24, separator: ' ', omission: '')
    string
  end

end
