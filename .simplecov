SimpleCov.start "rails" do
  # any custom configs like groups and filters can be here at a central place
  add_filter "/factories/"
  merge_timeout 7200
  command_name ENV["TEST_GROUP"].gsub(/[^\w]/, "_") if ENV["TEST_GROUP"]
end
