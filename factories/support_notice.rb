require "faker"

FactoryBot.define do
  factory :support_notice do
    sequence(:notice_content) { |n| "#{Faker::Lorem.paragraph} (#{n})" }

    active { false }
    support_notice_type { "notice" }

    trait :active do
      active { true }
    end

    trait :notice do
      support_notice_type { "notice" }
    end

    trait :caution do
      support_notice_type { "caution" }
    end

    trait :error do
      support_notice_type { "error" }
    end
  end
end
