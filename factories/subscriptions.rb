require 'faker'

FactoryGirl.define do

  factory :subscription do
    subscribable_type "Series"
    subscribable_id { FactoryGirl.create(:series).id }
    user
  end
end