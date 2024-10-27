require "faker"

FactoryBot.define do
  factory :reading do
    user_id { FactoryBot.create(:user).id }
    work_id { FactoryBot.create(:work).id }

    # A reading with a deleted work means a reading with a work_id that
    # doesn't exist. Here we use 0 because it will never be used as an id.
    trait :deleted_work do
      work_id { 0 }
    end
  end
end
