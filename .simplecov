SimpleCov.start "rails" do
  # any custom configs like groups and filters can be here at a central place
  add_filter "/factories/"
  merge_timeout 7200
end
