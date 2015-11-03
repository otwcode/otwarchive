require 'faker'

FactoryGirl.define do
  factory :feedback do
    comment [Faker::Lorem.paragraph(1)]
    email {Faker::Internet.email}
    summary {Faker::Lorem.sentence(1)}
    category 11483
  end
end