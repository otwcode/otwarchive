require 'faker'

FactoryGirl.define do
  factory :prompt_restriction do |f|
    f.optional_tags_allowed true
  end
end
