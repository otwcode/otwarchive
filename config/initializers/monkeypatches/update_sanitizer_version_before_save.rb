module ActiveRecord
  class Base
    before_save :update_sanitizer_version
    def update_sanitizer_version
      ArchiveConfig.FIELDS_ALLOWING_HTML.each do |field|
        if self.respond_to?("saved_change_to_#{field}?") && self.send("saved_change_to_#{field}?")
          self.send("#{field}_sanitizer_version=", ArchiveConfig.SANITIZER_VERSION)
        end
      end
    end
  end
end
