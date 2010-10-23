
# Site configuration (needed before Initializer)
require 'ostruct'
require 'yaml'
hash = YAML.load_file("#{Rails.root}/config/config.yml")
if File.exist?("#{Rails.root}/config/local.yml") && !Rails.env.test?
  hash.merge! YAML.load_file("#{Rails.root}/config/local.yml")
end
::ArchiveConfig = OpenStruct.new(hash)

# has to be run after ArchiveConfig loaded
# and only for production
if Rails.env == 'production'
  Otwarchive::Application.config.middleware.use ExceptionNotifier,
      :email_prefix => ArchiveConfig.ERROR_PREFIX,
      :sender_address => ArchiveConfig.RETURN_ADDRESS,
      :exception_recipients => ArchiveConfig.ERROR_ADDRESS
end


### more items here preserved from Rails 2 environment.rb that might not belong here
ActionController::AbstractRequest.relative_url_root = ArchiveConfig.PRODUCTION_URL_ROOT if ArchiveConfig.PRODUCTION_URL_ROOT && ENV['RAILS_ENV'] == 'production'

class ActiveRecord::Base
  include FindRandom
end
### end of preservation section

