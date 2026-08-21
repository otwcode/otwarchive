require "faker"

FactoryBot.define do
  factory :admin_post_tag do
    name { Faker::Lorem.unique.word }
    language { Language.default }
  end
end
