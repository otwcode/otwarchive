require 'faker'

FactoryGirl.define do

  sequence(:wrangling_guideline_title) do |n|
    "The #{n} Wrangling Guideline"
  end

  sequence(:content) do |n|
    "This is the #{n} Wrangling Guideline"
  end

  factory :wrangling_guideline do |f|
    title {generate(:wrangling_guideline_title)}
    content
  end

end