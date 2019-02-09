require "faker"

FactoryGirl.define do
  sequence(:series_title) do |n|
    "Awesome Series #{n}"
  end

  factory :series do
    title { generate(:series_title) }

    factory :series_with_a_work do
      after(:build) do |series|
        series.works = [create(:posted_work)]
      end
    end
  end
end
