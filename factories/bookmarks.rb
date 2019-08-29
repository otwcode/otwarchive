require 'faker'

FactoryBot.define do
  factory :bookmark do
    bookmarkable_type { "Work" }
    bookmarkable_id { FactoryBot.create(:work).id }
    pseud_id { FactoryBot.create(:pseud).id }
  end
end
