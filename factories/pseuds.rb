require 'faker'

FactoryGirl.define do
  factory :pseud do
    name { Faker::Lorem.characters(8) }
    association :user, :active
  end
end
