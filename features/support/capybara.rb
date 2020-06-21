require 'capybara/poltergeist'

# Produce a screenshot for each failure.
require 'capybara-screenshot/cucumber'

Capybara.configure do |config|
  # Capybara 1.x behavior.
  config.match = :prefer_exact

  config.ignore_hidden_elements = false

  # Increased timeout to minimise failures on CI servers.
  config.default_max_wait_time = 25
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist

def http_delete(path)
  if Capybara.current_driver == :poltergeist
    visit root_path if page.current_path.nil?
    page.evaluate_script("jQuery.ajax({url: '#{path}', data: {}, type: 'DELETE'});")
    wait_for_ajax
  else
    page.driver.submit :delete, path, {}
  end
end
