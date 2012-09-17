Factory.define :user do |f|
  f.sequence(:login) { |n| "testuser#{n}" }
  f.password "password"
  f.age_over_13 '1'
  f.terms_of_service '1'
  f.password_confirmation { |u| u.password }
  f.sequence(:email) { |n| "foo#{n}@archiveofourown.org" }
end

Factory.define :pseud do |f|
  f.sequence(:name) { |n| "test pseud #{n}" }
  f.association :user
end

Factory.define :admin do |f|
  f.sequence(:login) { |n| "testadmin#{n}" }
  f.password "password"
  f.password_confirmation { |u| u.password }
  f.sequence(:email) { |n| "foo#{n}@archiveofourown.org" }
end

Factory.define :archive_faq do |f|
  f.sequence(:title) { |n| "The #{n} FAQ" }
  f.sequence(:content) { |n| "This is the #{n} FAQ" }
end

Factory.define :tag do |f|
  f.canonical true
  f.sequence(:name) { |n| "The #{n} Tag" }
end

Factory.define :unsorted_tag do |f|
  f.sequence(:name) { |n| "Unsorted Tag #{n}"}
end

Factory.define :fandom do |f|
  f.canonical true
  f.sequence(:name) { |n| "The #{n} Fandom" }
end

Factory.define :character do |f|
  f.canonical true
  f.sequence(:name) { |n| "Character #{n}" }
end

Factory.define :relationship do |f|
  f.canonical true
  f.sequence(:name) { |n| "Jane#{n}/John#{n}" }
end

Factory.define :freeform do |f|
  f.canonical true
  f.sequence(:name) { |n| "Freeform #{n}" }
end



Factory.define :chapter do |f|
  f.content "Awesome content!"
  f.association :work
end

# Factory.define :chapter do |f|
#   f.content "Content of a chapter"
#   # f.authors [ Factory.create(:pseud) ]
#   f.after_build do |chapter|
#     chapter.authors = [ Factory.build(:pseud) ] if chapter.authors.blank?
#   end
# end

Factory.define :work do |f|
  f.title "My title"
  f.fandom_string "Testing"
  f.rating_string "Not Rated"
  f.warning_string "No Archive Warnings Apply"
  chapter_info = { content: "This is some chapter content for my work." }
  f.chapter_attributes chapter_info

  f.after_build do |work|
    work.authors = [Factory.build(:pseud)] if work.authors.blank?
  end
end

Factory.define :series do |f|
  f.sequence(:title) { |n| "Awesome Series #{n}" }
end

Factory.define :bookmark do |f|
  f.bookmarkable_type "Work"
  f.bookmarkable_id { Factory.create(:work).id }
  f.pseud_id { Factory.create(:pseud).id }
end

Factory.define :external_work do |f|
  f.title "An External Work"
  f.author "An Author"
  f.url "http://www.example.org"

  f.after_build do |work|
    work.fandoms = [Factory.build(:fandom)] if work.fandoms.blank?
  end
end

Factory.define :collection_participant do |f|
  f.association :pseud
  f.participant_role "Owner"
end

Factory.define :collection_preference do |f|
  f.association :collection
end

Factory.define :collection_profile do |f|
  f.association :collection
end

Factory.define :collection do |f|
  f.sequence(:name) {|n| "basic_collection_#{n}"}
  f.sequence(:title) {|n| "Basic Collection #{n}"}
    
  f.after_build do |collection|
    collection.collection_participants.build(pseud_id: Factory.create(:pseud).id, participant_role: "Owner")
  end
end

Factory.define :subscription do |f|
  f.association :user
  f.subscribable_type "Series"
  f.subscribable_id { Factory.create(:series).id }
end
