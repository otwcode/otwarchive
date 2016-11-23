require 'webmock/cucumber'

After("@import") do
  WebMock.reset!
end
