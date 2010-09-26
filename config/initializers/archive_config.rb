
# Site configuration (needed before Initializer)
require 'ostruct'
require 'yaml'
hash = YAML.load_file("#{config.root}/config/config.yml")
if File.exist?("#{config.root}/config/local.yml") && ENV['RAILS_ENV'] != 'test'
  hash.merge! YAML.load_file("#{config.root}/config/local.yml")
end
::ArchiveConfig = OpenStruct.new(hash)

### more items here preserved from Rails 2 environment.rb that might not belong here
ActionController::AbstractRequest.relative_url_root = ArchiveConfig.PRODUCTION_URL_ROOT if ArchiveConfig.PRODUCTION_URL_ROOT && ENV['RAILS_ENV'] == 'production'

class ActiveRecord::Base
    include FindRandom
end
### end of preservation section
