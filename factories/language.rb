# frozen_string_literal: true

FactoryBot.define do
  factory :language do
    short { "nl" }
    name { "Dutch" }

    after(:build) do |language|
      language.sortable_name = language.short if language.sortable_name.blank?
    end
  end
end
