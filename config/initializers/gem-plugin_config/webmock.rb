if Rails.env.test?
  # net_http_connect_on_start: https://stackoverflow.com/questions/59632283/chromedriver-capybara-too-many-open-files-socket2-for-127-0-0-1-port-951
  # limited to localhost: https://github.com/bblimke/webmock/issues/955#issuecomment-1373962511
  WebMock.allow_net_connect!(net_http_connect_on_start: %w[127.0.0.1 localhost])
  WebMock.enable!
end
