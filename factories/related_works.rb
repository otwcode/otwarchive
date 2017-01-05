require 'faker'

FactoryGirl.define do
  factory :related_work do
    parent_type "Work"
    parent_id { FactoryGirl.create(:work).id }
    work_id { FactoryGirl.create(:work).id }
  end
end
