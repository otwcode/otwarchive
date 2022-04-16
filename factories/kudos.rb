require 'faker'

FactoryBot.define do
  factory :kudo do |f|
    f.commentable_id { FactoryBot.create(:work).id }
    f.commentable_type { "Work" }
  end
end
