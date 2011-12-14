Factory.define :user do |f|  
  f.sequence(:login) { |n| "testuser#{n}" }   
  f.password "password"
  f.age_over_13 '1'
  f.terms_of_service '1' 
  f.password_confirmation { |u| u.password }  
  f.sequence(:email) { |n| "foo#{n}@archiveofourown.org" }  
end

Factory.define :pseud do |f|  
  f.name "my test pseud"  
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

Factory.define :admin_post do |f|  
  f.sequence(:title) { |n| "The #{n} Admin Post Title" }
  f.sequence(:content) { |n| "This is the #{n} admin post content." }
end

# tags
Factory.define :tag do |f|
  f.canonical true
  f.sequence(:name) { |n| "The #{n} Tag" }
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

#works
Factory.define :chapter do |f|
  f.content "Awesome content!"
  f.association :work
end

Factory.define :work do |f|
  f.title "My title"

  f.after_build do |work|
    work.chapters = [Factory.build(:chapter, :work => work)] if work.chapters.blank?
    work.authors = [Factory.build(:pseud)] if work.authors.blank?
    work.fandoms = [Factory.build(:fandom)] if work.fandoms.blank?
    work.characters = [Factory.build(:character)] if work.characters.nil?
    work.relationships = [Factory.build(:relationship)] if work.relationships.nil?
    work.freeforms = [Factory.build(:freeform)] if work.freeforms.nil?
  end
end

# Factory.define :collection_participant do |f|
#   f.association :pseud
#   f.association :collection
#   f.participant_role = "Owner"
# end
# 
# Factory.define :collection_preference do |f|
#   f.association :collection
# end
# 
# Factory.define :collection_profile do |f|
#   f.association :collection
# end
# 
# Factory.define :collection do |f|
#   f.sequence(:name) = {|n| "basic_collection_#{n}"}
#   f.sequence(:title) = {|n| "Basic Collection #{n}"}
#   
#   f.association :user
#   f.association :collection_preference
#   f.association :collection_profile
# end
