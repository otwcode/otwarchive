require "redis_test_setup"
include RedisTestSetup # rubocop:disable Style/MixinUsage

rails_root = ENV["RAILS_ROOT"] || "#{File.dirname(__FILE__)}/../../.."
rails_env = (ENV["RAILS_ENV"] || "development").to_sym

# https://gist.github.com/441072
start_redis!(rails_root, :cucumber) if rails_env == :test && !(ENV["CI"] || ENV["DOCKER"])

redis_configs = YAML.load_file("#{rails_root}/config/redis.yml", symbolize_names: true)
redis_configs.each_pair do |name, redis_config|
  redis_options = {}
  if redis_config[rails_env].is_a?(Hash)
    # example:
    # redis_kudos:
    #   development
    #     name: redis_kudos
    #     sentinels:
    #       - host: 127.0.0.1
    #         port: 26379
    #       - host: 127.0.0.1
    #         port: 26380
    redis_options = redis_config[rails_env]
  else
    redis_host, redis_port = redis_config[rails_env].split(":")
    redis_options[:host] = redis_host
    redis_options[:port] = redis_port
  end
  redis_connection = Redis.new(redis_options)
  if ENV["DEV_USER"]
    namespaced_redis = Redis::Namespace.new(ENV["DEV_USER"], redis: redis_connection)
    redis_connection = namespaced_redis
  end
  Object.const_set(name.upcase, redis_connection)
end
