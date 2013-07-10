require 'faker'

FactoryGirl.define do
  factory :abuse_report do
    email {Faker.Internet.email}
    url {Faker.Internet.domain_name}
    comment {Faker.Lorem.paragraph(3)}
    category {1}
  end
end