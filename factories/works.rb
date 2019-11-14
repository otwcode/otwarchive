require 'faker'
FactoryBot.define do

  factory :work do
    title { "My title is long enough" }
    fandom_string { "Testing" }
    rating_string { "Not Rated" }
    archive_warning_string { "No Archive Warnings Apply" }
    language_id { Language.default.id }
    chapter_info = { content: "This is some chapter content for my work." }
    chapter_attributes { chapter_info }

    transient do
      authors { [build(:pseud)] }
    end

    after(:build) do |work, evaluator|
      evaluator.authors.each do |pseud|
        work.creatorships.build(pseud: pseud)
      end
    end

    factory :no_authors do
      authors { [] }
    end

    factory :custom_work_skin do
      work_skin_id { 1 }
    end

    # create(:work_with_chapters) will create a work with 2 chapters by default
    # create(:work_with_chapters, chapters_count: 3) lets you specify how many
    # chapters the work should have
    factory :work_with_chapters do
      transient do
        chapters_count 2
      end

      after(:create) do |work, evaluator|
        # a work technically starts off with 1 chapter, so we need to make 1
        # less than the desired total
        chapters_to_create = evaluator.chapters_count.to_i - 1
        create_list(:chapter, chapters_to_create, work_id: work.id, posted: true)
      end
    end

    factory :posted_work do
      posted { true }
    end

    factory :draft do
      posted { false }
    end
  end

  factory :external_work do
    title { "An External Work" }
    author { "An Author" }
    url { "http://www.example.org" }

    after(:build) do |work|
      work.fandoms = [FactoryBot.build(:fandom)] if work.fandoms.blank?
    end
  end

  factory :external_author do |f|
    f.sequence(:email) { |n| "foo#{n}@external.com" }
  end

  factory :external_author_name do |f|
    f.association :external_author
  end

  factory :external_creatorship do |f|
    f.creation_type { 'Work' }
    f.association :external_author_name
  end
end
