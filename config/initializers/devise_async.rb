Devise::Async.setup do |config|
  config.enabled = true
  config.backend = :resque
end
