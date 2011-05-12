Factory.define :user do |f|
  f.sequence(:login) { |n| "factoryuser#{n}" }
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
  f.sequence(:id) { |n| n }
  f.sequence(:title) { |n| "The #{n} FAQ" }
  f.sequence(:content) { |n| "This is the #{n} FAQ" }
end

Factory.define :fandom do |f|
  f.sequence(:name) { |n| "Test Fandom #{n}" }
  f.canonical true
end

Factory.define :character do |f|
  f.sequence(:name) { |n| "Test Character #{n}" }
  f.canonical true
end

Factory.define :relationship do |f|
  f.sequence(:name) { |n| "Test Character#{n}/Another Test#{n}" }
  f.canonical true
end
