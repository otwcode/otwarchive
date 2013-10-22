FactoryGirl.define do
  factory :user do |f|
    f.sequence(:login) { |n| "testuser#{n}" }
    f.password "password"
    f.age_over_13 '1'
    f.terms_of_service '1'
    f.password_confirmation { |u| u.password }
    f.sequence(:email) { |n| "foo#{n}@archiveofourown.org" }
  end

  factory :pseud do |f|
    f.sequence(:name) { |n| "test pseud #{n}" }
    f.association :user
  end

  factory :admin do |f|
    f.sequence(:login) { |n| "testadmin#{n}" }
    f.password "password"
    f.password_confirmation { |u| u.password }
    f.sequence(:email) { |n| "foo#{n}@archiveofourown.org" }
  end

  factory :admin_post do |f|
    f.sequence(:title) { |n| "Amazing News #{n}"}
    f.sequence(:content) {|n| "This is the content for the #{n} Admin Post"}

    after(:build) do |admin_post|
      admin_post.admin_id = [FactoryGirl.build(:admin).id] if admin_post.admin_id.blank?
    end
  end

  factory :archive_faq do |f|
    f.sequence(:title) { |n| "The #{n} FAQ" }
    f.sequence(:content) { |n| "This is the #{n} FAQ" }
  end

  factory :tag do |f|
    f.canonical true
    f.sequence(:name) { |n| "The #{n} Tag" }
  end

  factory :unsorted_tag do |f|
    f.sequence(:name) { |n| "Unsorted Tag #{n}"}
  end

  factory :fandom do |f|
    f.canonical true
    f.sequence(:name) { |n| "The #{n} Fandom" }
  end

  factory :character do |f|
    f.canonical true
    f.sequence(:name) { |n| "Character #{n}" }
  end

  factory :relationship do |f|
    f.canonical true
    f.sequence(:name) { |n| "Jane#{n}/John#{n}" }
  end

  factory :freeform do |f|
    f.canonical true
    f.sequence(:name) { |n| "Freeform #{n}" }
  end

  factory :chapter do |f|
    f.content "Awesome content!"
    f.association :work
  end

  # factory :chapter do |f|
  #   f.content "Content of a chapter"
  #   # f.authors [ FactoryGirl.create(:pseud) ]
  #   after(:build) do |chapter|
  #     chapter.authors = [ FactoryGirl.build(:pseud) ] if chapter.authors.blank?
  #   end
  # end

  factory :work do |f|
    f.title "My title"
    f.fandom_string "Testing"
    f.rating_string "Not Rated"
    f.warning_string "No Archive Warnings Apply"
    chapter_info = { content: "This is some chapter content for my work." }
    f.chapter_attributes chapter_info

    after(:build) do |work|
      work.authors = [FactoryGirl.build(:pseud)] if work.authors.blank?
    end
  end

  factory :series do |f|
    f.sequence(:title) { |n| "Awesome Series #{n}" }
  end

  factory :bookmark do |f|
    f.bookmarkable_type "Work"
    f.bookmarkable_id { FactoryGirl.create(:work).id }
    f.pseud_id { FactoryGirl.create(:pseud).id }
  end

  factory :external_work do |f|
    f.title "An External Work"
    f.author "An Author"
    f.url "http://www.example.org"

    after(:build) do |work|
      work.fandoms = [FactoryGirl.build(:fandom)] if work.fandoms.blank?
    end
  end

  factory :collection_participant do |f|
    f.association :pseud
    f.participant_role "Owner"
  end

  factory :collection_preference do |f|
    f.association :collection
  end

  factory :collection_profile do |f|
    f.association :collection
  end

  factory :collection do |f|
    f.sequence(:name) {|n| "basic_collection_#{n}"}
    f.sequence(:title) {|n| "Basic Collection #{n}"}
      
    after(:build) do |collection|
      collection.collection_participants.build(pseud_id: FactoryGirl.create(:pseud).id, participant_role: "Owner")
    end
  end

  factory :subscription do |f|
    f.association :user
    f.subscribable_type "Series"
    f.subscribable_id { FactoryGirl.create(:series).id }
  end

  factory :owned_tag_set do |f|
    f.sequence(:title) {|n| "Owned Tag Set #{n}"}
    f.nominated true
    after(:build) do |owned_tag_set|
      owned_tag_set.build_tag_set
      owned_tag_set.add_owner(FactoryGirl.create(:pseud))
    end
  end

  factory :tag_set_nomination do |f|
    f.association :owned_tag_set
    f.association :pseud
  end

  factory :challenge_assignment do |f| 
    after(:build) do |assignment|
      assignment.collection_id = FactoryGirl.create(:collection, :challenge => GiftExchange.new).id unless assignment.collection_id
      assignment.request_signup = FactoryGirl.create(:challenge_signup, :collection_id => assignment.collection_id)
      assignment.offer_signup = FactoryGirl.create(:challenge_signup, :collection_id => assignment.collection_id)
    end
  end

  factory :challenge_signup do |f|
    after(:build) do |signup|
      signup.pseud_id = FactoryGirl.create(:pseud).id unless signup.pseud_id
      signup.collection_id = FactoryGirl.create(:collection, :challenge => GiftExchange.new).id unless signup.collection_id
      signup.offers.build(pseud_id: signup.pseud_id, collection_id: signup.collection_id)
      signup.requests.build(pseud_id: signup.pseud_id, collection_id: signup.collection_id)
    end
  end
end
