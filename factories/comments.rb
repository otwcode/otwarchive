require 'faker'

FactoryBot.define do
  factory :comment do
    name { Faker::Name.first_name }
    comment_content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "Work" }
    commentable_id { create(:work).id }
    pseud
  end

  factory :adminpost_comment, class: Comment do
    name { Faker::Name.first_name }
    comment_content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "AdminPost" }
    commentable_id { create(:admin_post).id }
    pseud
  end

  factory :tag_comment, class: Comment do
    name { Faker::Name.first_name }
    comment_content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "Tag" }
    commentable_id { create(:fandom).id }
    pseud
  end

  factory :unreviewed_comment, class: Comment do
    name { Faker::Name.first_name }
    comment_content { Faker::Lorem.sentence(25) }
    email { Faker::Internet.email }
    commentable_type { "Work" }
    commentable_id { create(:work, moderated_commenting_enabled: true).id }
    pseud
    unreviewed { true }
  end

  factory :inbox_comment do
    user { create(:user) }
    feedback_comment { create(:comment) }
  end
end
