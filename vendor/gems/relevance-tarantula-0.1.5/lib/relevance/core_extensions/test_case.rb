class Test::Unit::TestCase
  def tarantula_crawl(integration_test, options = {})
    url = options[:url] || "/"
    t = tarantula_crawler(integration_test, options)
    t.crawl url
  end
  
  def tarantula_crawler(integration_test, options = {})
    Relevance::Tarantula::RailsIntegrationProxy.rails_integration_test(integration_test, options)
  end
end

