
# Site configuration (needed before Initializer)
require 'ostruct'
require 'yaml'
hash = YAML.load_file("#{Rails.root}/config/config.yml")
if File.exist?("#{Rails.root}/config/local.yml")
  hash.merge! YAML.load_file("#{Rails.root}/config/local.yml")
end
::ArchiveConfig = OpenStruct.new(hash)

### more items here preserved from Rails 2 environment.rb that might not belong here
ActionController::AbstractRequest.relative_url_root = ArchiveConfig.PRODUCTION_URL_ROOT if ArchiveConfig.PRODUCTION_URL_ROOT && ENV['RAILS_ENV'] == 'production'
### end of preservation section

