require "faker"

FactoryBot.define do
  sequence(:faq_title) do |n|
    "The #{n} FAQ"
  end

  factory :archive_faq do
    title { generate(:faq_title) }
  end
end
