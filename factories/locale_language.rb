# frozen_string_literal: true

FactoryBot.define do
  sequence(:locale_language_short) { |n| "l#{n}" }
  sequence(:locale_language_name) { |n| "Locale Language #{n}" }

  factory :locale_language do
    short { generate(:locale_language_short) }
    name { generate(:locale_language_name) }
  end
end
