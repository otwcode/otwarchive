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

Factory.define :fandom do |f|
  f.sequence(:name) { |n| "Test Fandom #{n}" }
  f.canonical true
end

