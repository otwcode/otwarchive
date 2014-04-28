require 'faker'

FactoryGirl.define do
  factory :comment do
    name {Faker::Name.first_name}
    content {Faker::Lorem.sentence(25)}
    email {Faker::Internet.email}
    commentable_type {"Work"}
    commentable_id { FactoryGirl.create(:work).id }
    pseud
  end
end