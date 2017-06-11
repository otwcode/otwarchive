require "faker"

FactoryGirl.define do
  factory :favorite_tag do
    tag_id { FactoryGirl.create(:freeform).id }
    user_id { FactoryGirl.create(:user).id }
  end
end
