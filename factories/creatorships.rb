require 'faker'
FactoryBot.define do

  factory :creatorships do
    title { "My title is long enough" }

    transient do
      authors { [build(:pseud)] }
    end

    after(:build) do |work, evaluator|
      evaluator.authors.each do |pseud|
        work.creatorships.build(pseud: pseud)
      end
    end

  end
end
