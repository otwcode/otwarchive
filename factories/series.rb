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

    after(:create) do |series|
      create(:work, authors: series.pseuds, series: [series]) if series.works.empty?
    end
  end
end
