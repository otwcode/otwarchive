if Rails.env.staging?
  CopycopterClient.configure do |config|
    config.api_key = 'bc9ac482bbb2dc056b55734ea306e5a3ef2cf9caec60c8be'
    config.host = '10.10.11.126'
    config.port = 3000
  end
end
