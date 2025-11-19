require 'faker'

FactoryBot.define do
  factory :chapter do
    content { "Awesome content!" }
    work
    posted { true }

    transient do
      authors { work.pseuds }
      year { nil }
    end

    after(:build) do |chapter, evaluator|
      evaluator.authors.each do |pseud|
        chapter.creatorships.build(pseud: pseud)
      end
    end

    after(:build) do |chapter, evaluator|
      chapter.published_at = Date.new(evaluator.year, 1, 1) if evaluator.year
    end

    trait :draft do
      content { "Draft content!" }
      posted { false }
    end
  end
end
