# Include in classes that can own a downloadable object
module DownloadableOwner
  
  def self.included(downloadable)
    downloadable.class_eval do
      before_update :expire_downloads
      before_destroy :expire_downloads
    end
  end

  # Whenever a works owner changes or is destroyed, the downloads of any works that it "owns" 
  # become invalid
  def expire_downloads
    if self.respond_to?(:works)
      self.works.each {|w| w.remove_outdated_downloads}
    end
  end
  
end
