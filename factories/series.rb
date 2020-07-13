require "faker"

FactoryBot.define do
  sequence(:series_title) do |n|
    "Awesome Series #{n}"
  end

  factory :series do
    title { generate(:series_title) }

    transient do
      authors { [build(:pseud)] }
    end

    after(:build) do |series, evaluator|
      evaluator.authors.each do |pseud|
        series.creatorships.build(pseud: pseud)
      end
    end

    factory :series_with_a_work do
      work_ids { [create(:work).id] }
    end
  end
end
