
# Site configuration (needed before Initializer)
require 'ostruct'
require 'yaml'
hash = YAML.load(ERB.new(File.read("#{Rails.root}/config/config.yml")).result)
if File.exist?("#{Rails.root}/config/local.yml")
  hash.merge! YAML.load(ERB.new(File.read("#{Rails.root}/config/local.yml")).result)
end
::ArchiveConfig = OpenStruct.new(hash)

### more items here preserved from Rails 2 environment.rb that might not belong here
ActionController::AbstractRequest.relative_url_root = ArchiveConfig.PRODUCTION_URL_ROOT if ArchiveConfig.PRODUCTION_URL_ROOT && ENV['RAILS_ENV'] == 'production'
### end of preservation section

