class Download

  def self.generate(work, mime_type)
    new(work, mime_type).generate
  end

  def self.remove(work)
    new(work, "text/html").remove
  end

  attr_reader :work

  def initialize(work, mime_type)
    @work = work
    @mime_type = mime_type
  end

  def generate
    DownloadWriter.new(self).write
  end

  def exists?
    File.exists?(file_path)
  end

  def remove
    FileUtils.rm_rf(dir)
  end

  def file_type
    ext = MimeMagic.new(@mime_type.to_s).subtype
    ext == "x-mobipocket-ebook" ? "mobi" : ext
  end

  def file_name
    clean(work.title) || "Work #{work.id}"
  end

  def file_path
    "#{dir}/#{file_name}"
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
