Tire::Model::Search.index_prefix "#{Rails.application.class.parent_name.downcase}_#{Rails.env.to_s.downcase}"

if Rails.env == 'production' || Rails.env == 'staging'
  Tire.configure do
    url "http://elasticsearch01.ao3.org:9200"
  end
end