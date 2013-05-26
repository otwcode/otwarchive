if Rails.env.production? 
  Tire::Model::Search.index_prefix "#{Rails.application.class.parent_name.downcase}_production"
  Tire.configure do
    url "http://elasticsearch01.ao3.org:9200"
  end
elsif Rails.env.staging? 
  Tire::Model::Search.index_prefix "#{Rails.application.class.parent_name.downcase}_staging"
  Tire.configure do
    url "http://test-db01.transformativeworks.org:9200"
  end
else
  Tire::Model::Search.index_prefix "#{Rails.application.class.parent_name.downcase}_#{Rails.env.to_s.downcase}"
end
