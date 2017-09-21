class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.per_page = ArchiveConfig.ITEMS_PER_PAGE

  before_save :update_sanitizer_version

  def update_sanitizer_version
    ArchiveConfig.FIELDS_ALLOWING_HTML.each do |field|
      if self.will_save_change_to_attribute?(field)
        self.send("#{field}_sanitizer_version=", ArchiveConfig.SANITIZER_VERSION)
      end
    end
  end

  def self.use_new_search?
    !es_version.match "0.90"
  end

  private

  def self.es_version
    @es_version ||= get_es_version
  end

  def self.get_es_version
    es_response = $elasticsearch.perform_request("GET", "/")
    if es_response.status == 200
      es_response.body["version"]["number"]
    else
      raise es_response.inspect
    end
  end

end
