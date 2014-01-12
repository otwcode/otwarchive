module Downloadable

  def self.included(downloadable)
    downloadable.class_eval do
      after_update :remove_outdated_downloads
    end
  end

  # called from after_update to get rid of old downloads folder
  def remove_outdated_downloads
    FileUtils.rm_rf(self.download_dir)
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

end