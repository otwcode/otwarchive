require 'faker'

FactoryGirl.define do
  factory :bookmark do
    bookmarkable_type "Work"
    bookmarkable_id { FactoryGirl.create(:work).id }
    pseud_id { FactoryGirl.create(:pseud).id }
  end

end