require 'faker'

FactoryBot.define do
  factory :admin_post do
    language { Language.default }
    admin_id { FactoryBot.create(:admin).id }
    title { "AdminPost Title" }
    content { "AdminPost content long enough to pass validation" }
    posted { true }
    published_at { Time.current }

    trait :draft do
      posted { false }
      published_at { nil }
    end
  end
end
