# frozen_string_literal: true

FactoryBot.define do
  factory :language do
    short { "nl" }
    name { "Dutch" }

    after(:build) do |language|
      # TODO: update this to use the name instead of short as a fallback. This will require a fair few test changes too.
      language.sortable_name = language.short if language.sortable_name.blank?
    end
  end
end
