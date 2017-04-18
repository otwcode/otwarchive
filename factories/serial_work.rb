require 'faker'

FactoryGirl.define do
  factory :serial_work do
    work_id { FactoryGirl.create(:work).id }
  end
end
