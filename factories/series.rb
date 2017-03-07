require 'faker'

FactoryGirl.define do

  sequence(:series_title) do |n|
    "Awesome Series #{n}"
  end

  factory :series do
    title {generate(:series_title)}
  end
end
