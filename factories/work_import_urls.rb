FactoryBot.define do
  factory :work_import_url do
    work
    url { "http://example.com/story" }
  end
end
