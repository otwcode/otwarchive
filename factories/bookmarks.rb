require "faker"

FactoryBot.define do
  factory :bookmark do
    bookmarkable_type { "Work" }
    bookmarkable_id { create(:work).id }
    pseud_id { create(:pseud).id }

    factory :external_work_bookmark do
      bookmarkable_type { "ExternalWork" }
      bookmarkable_id { create(:external_work).id }
    end

    factory :series_bookmark do
      bookmarkable_type { "Series" }
      bookmarkable_id { create(:series).id }
    end
  end
end
