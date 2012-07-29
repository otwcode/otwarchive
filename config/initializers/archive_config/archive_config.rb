
# Site configuration (needed before Initializer)
require 'ostruct'
require 'yaml'
YAML::ENGINE.yamler= 'syck'
hash = YAML.load_file("#{Rails.root}/config/config.yml")
if !Rails.env.test?
  hash.merge! YAML.load_file("#{Rails.root}/config/local.yml")
end
::ArchiveConfig = OpenStruct.new(hash)

# has to be run after ArchiveConfig loaded
# and only for production
if Rails.env == 'production'
  Airbrake.configure do |config|
    config.api_key  = ArchiveConfig.ERRBIT_KEY
    config.host     = ArchiveConfig.ERRBIT_HOST
    config.port     = 80
    config.secure   = config.port == 443
    config.params_filters << ["email", "crypted_password", "salt"]
  end
end



### more items here preserved from Rails 2 environment.rb that might not belong here
ActionController::AbstractRequest.relative_url_root = ArchiveConfig.PRODUCTION_URL_ROOT if ArchiveConfig.PRODUCTION_URL_ROOT && ENV['RAILS_ENV'] == 'production'

class ActiveRecord::Base
  include FindRandom
end
### end of preservation section

