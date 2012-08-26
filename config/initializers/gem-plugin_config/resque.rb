require 'resque'
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../../..'
rails_env = ENV['RAILS_ENV'] || 'development'

redis_config = YAML.load_file(rails_root + '/config/redis.yml')
Resque.redis = redis_config[rails_env]

# in-process performing of jobs (for testing) doesn't require a redis server
Resque.inline = ENV['RAILS_ENV'] == "test"
