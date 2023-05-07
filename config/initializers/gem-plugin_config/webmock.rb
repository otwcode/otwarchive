if Rails.env.test?
  # https://stackoverflow.com/questions/59632283/chromedriver-capybara-too-many-open-files-socket2-for-127-0-0-1-port-951
  WebMock.allow_net_connect!(net_http_connect_on_start: true)
  WebMock.enable!
end
