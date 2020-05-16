module HttpHelpers
  def http_delete(path)
    current_driver = Capybara.current_driver
    Capybara.current_driver = :rack_test
    page.driver.submit :delete, path, {}
    Capybara.current_driver = current_driver
  end
end
World(HttpHelpers)