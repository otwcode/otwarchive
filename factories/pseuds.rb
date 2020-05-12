require 'faker'

FactoryBot.define do
  factory :pseud do
    name { Faker::Lorem.characters(8) }
    user
  end
end
