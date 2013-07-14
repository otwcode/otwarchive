require 'faker'
FactoryGirl.define do

  sequence(:login) do |n|
    "#{Faker::Lorem.characters(8)}#{n}"
  end

  sequence :email do |n|
    Faker::Internet.email(name="#{Faker::Name.first_name}_#{n}")
  end
  sequence :admin_login do |n|
    "testadmin#{n}"
  end

  factory :user do
    login {generate(:login)}
    password "password"
    age_over_13 '1'
    terms_of_service '1'
    password_confirmation { |u| u.password }
    email {generate(:email)}
    factory :duplicate_user do
      login "placeholder"
      email "placeholder"
    end

    factory :invited_user do
      login {generate(:login)}
      invitation_token nil
    end
  end


  factory :pseud do
    name {Faker::Lorem.word}
    user
  end

  factory :admin do
    login
    password "password"
    password_confirmation { |u| u.password }
    email
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

    factory :no_authors, parent: :work do
      after(:build) do |work|
        work.authors = []
      end
    end

    factory :custom_work_skin do
      skin_id {FactoryGirl.create(:skin) if work.skin_id.blank?}
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

  factory :invite_request do
    email
  end

  factory :invitation do
    invitee_email "default@email.com"
  end

  factory :skin do
      author_id {FactoryGirl.create(:user).id}
      title {Faker::Lorem.word}
      type "WorkSkin"

      factory :private_skin do

      end
  end

end