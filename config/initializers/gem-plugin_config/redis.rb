require 'redis_test_setup'
include RedisTestSetup

if ENV['TRAVIS']
  rails_root = ENV['TRAVIS_BUILD_DIR']
  rails_env = 'test'
else
  rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../../..'
  rails_env = ENV['RAILS_ENV'] || 'development'
end

unless ENV['TRAVIS']
  if rails_env == "test"
    # https://gist.github.com/441072
    start_redis!(rails_root, :cucumber)
  end
end

redis_configs = YAML.load_file(rails_root + '/config/redis.yml')
redis_configs.each_pair do |name, redis_config|
  redis_host, redis_port = redis_config[rails_env].split(":")
  Object.const_set(name.upcase, Redis.new(host: redis_host, port: redis_port))
end
