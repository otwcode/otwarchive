SimpleCov.add_filter 'vendor'
SimpleCov.formatters = []
SimpleCov.start 'rails'  do
  # any custom configs like groups and filters can be here at a central place
  merge_timeout 3600
end
