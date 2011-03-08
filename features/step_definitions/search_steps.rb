Given /^the (\w+) indexes are updated$/ do |model|
  model = model.titleize.gsub(/\s/, '').constantize
  ThinkingSphinx::Test.index *model.sphinx_index_names
  sleep(0.5) # Wait for Sphinx to catch up
end

Given /^remote sphinx is stopped$/ do
  # set up thinking sphinx the same as in production
  ThinkingSphinx.remote_sphinx = true
  ThinkingSphinx.updates_enabled = false
  # and stop it
  ThinkingSphinx::Configuration.instance.controller.stop
end

Given /^sphinx is started again$/ do
  ThinkingSphinx::Configuration.instance.controller.start
end
