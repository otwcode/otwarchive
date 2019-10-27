require 'faker'

FactoryBot.define do
  factory :chapter do
    content { "Awesome content!" }
    work

    transient do
      authors { work.pseuds }
    end

    after(:build) do |chapter, evaluator|
      evaluator.authors.each do |pseud|
        chapter.creatorships.build(pseud: pseud)
      end
    end
  end
end
