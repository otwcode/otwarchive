require 'faker'
FactoryGirl.define do
  factory :abuse_report do
    email {Faker::Internet.email}
    url "http://archiveofourown.org/tags/2000%20AD%20(Comics)/works"
    comment {Faker::Lorem.paragraph(1)}
    category 11469
    cc_me "0"
  end
end