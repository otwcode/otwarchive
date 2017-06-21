require 'faker'
FactoryGirl.define do

  factory :work do
    title "My title is long enough"
    fandom_string "Testing"
    rating_string "Not Rated"
    warning_string "No Archive Warnings Apply"
    chapter_info = { content: "This is some chapter content for my work." }
    chapter_attributes chapter_info

    after(:build) do |work|
      work.authors = [FactoryGirl.build(:pseud)] if work.authors.blank?
    end

    factory :no_authors do
      after(:build) do |work|
        work.authors = []
      end
    end

    factory :custom_work_skin do
      work_skin_id 1
    end
  end

  factory :external_work do
    title "An External Work"
    author "An Author"
    url "http://www.example.org"

    after(:build) do |work|
      work.fandoms = [FactoryGirl.build(:fandom)] if work.fandoms.blank?
    end
  end

  factory :external_author do |f|
    f.sequence(:email) { |n| "foo#{n}@external.com" }
  end

  factory :external_author_name do |f|
    f.association :external_author
  end

  factory :external_creatorship do |f|
    f.creation_type 'Work'
    f.association :external_author_name
  end

end
