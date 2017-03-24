require 'faker'

FactoryGirl.define do
  factory :comment do
    name { Faker::Name.first_name }
    content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "Work" }
    commentable_id { FactoryGirl.create(:work).id }
    pseud
  end

  factory :adminpost_comment, class: Comment do
    name { Faker::Name.first_name }
    content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "AdminPost" }
    commentable_id { FactoryGirl.create(:admin_post).id }
    pseud
  end

  factory :tag_comment, class: Comment do
    name { Faker::Name.first_name }
    content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "Tag" }
    commentable_id { FactoryGirl.create(:fandom).id }
    pseud
  end

  factory :unreviewed_comment, class: Comment do
    name { Faker::Name.first_name }
    content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "Work" }
    commentable_id { FactoryGirl.create(:work, moderated_commenting_enabled: true).id }
    pseud
    unreviewed true
  end
end
