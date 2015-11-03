require 'faker'

FactoryGirl.define do
  factory :kudo do |f|
    f.commentable_id { FactoryGirl.create(:work).id }
    f.commentable_type "Work"
  end
end