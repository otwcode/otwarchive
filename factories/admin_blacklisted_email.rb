require 'faker'

FactoryBot.define do
  factory :admin_blacklisted_email do
    email { Faker::Internet.unique.email }
  end
end
