# The default elasticsearch url is set in config.yml and can be overwritten in local.yml
Tire.configure do
  url ArchiveConfig.ELASTICSEARCH_URL
end
Tire::Model::Search.index_prefix "#{Rails.application.class.parent_name.downcase}_#{Rails.env.to_s.downcase}"
