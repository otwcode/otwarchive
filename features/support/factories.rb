Factory.define :user do |f|  
  f.sequence(:login) { |n| "testuser#{n}" }   
  f.password "password"
  f.age_over_13 '1'
  f.terms_of_service '1' 
  f.password_confirmation { |u| u.password }  
  f.sequence(:email) { |n| "foo#{n}@example.com" }  
end

Factory.define :pseud do |f|  
  f.name "my test pseud"  
  f.association :user  
end

Factory.define :admin do |f|  
  f.sequence(:login) { |n| "testadmin#{n}" }   
  f.password "password"  
  f.password_confirmation { |u| u.password }  
  f.sequence(:email) { |n| "foo#{n}@example.com" }  
end