require 'redis_test_setup'
include RedisTestSetup

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../../..'
rails_env = ENV['RAILS_ENV'] || 'development'

if rails_env == "test"
  # https://gist.github.com/441072
  start_redis!(rails_root, :cucumber)
end

redis_config = YAML.load_file(rails_root + '/config/redis.yml')
redis_host, redis_port = redis_config[rails_env].split(":")
$redis = Redis.new(:host => redis_host, :port => redis_port)


    
