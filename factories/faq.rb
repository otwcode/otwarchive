require "faker"

FactoryBot.define do
  sequence(:faq_title) do |n|
    "The #{n} FAQ"
  end

  sequence(:content) do |n|
    "This is the #{n} FAQ"
  end

  factory :archive_faq do |f|
    title { generate(:faq_title) }
  end
end
