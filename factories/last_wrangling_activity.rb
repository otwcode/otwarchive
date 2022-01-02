require "faker"

FactoryBot.define do
  factory :last_wrangling_activity do
    performed_at { Time.now.utc }
  end
end
