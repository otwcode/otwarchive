require 'faker'

FactoryGirl.define do
  factory :admin_post do
    admin_id { FactoryGirl.create(:admin).id }
    title "AdminPost Title"
    content "AdminPost content long enough to pass validation"
  end
end