class Person < ActiveRecord::Base
  belongs_to :team, :polymorphic => :true
  has_many :contacts
  
  has_many :friendships
  has_many :friends, :through => :friendships
  
  define_index do
    indexes [first_name, middle_initial, last_name], :as => :name
    indexes team.name, :as => :team_name
    indexes contacts.phone_number, :as => :phone_numbers
    
    has [first_name, middle_initial, last_name], :as => :name_sort
    has team.name, :as => :team_name_sort
    
    has [:id, :team_id], :as => :ids
    has team(:id), :as => :team_id
    
    has contacts.phone_number, :as => :phone_number_sort
    has contacts(:id), :as => :contact_ids
    
    has birthday
    
    has friendships.person_id, :as => :friendly_ids
  end
end

class Parent < Person
end

class Child < Person
  belongs_to :parent
  define_index do
    indexes [parent.first_name, parent.middle_initial, parent.last_name], :as => :parent_name
  end
end

class Contact < ActiveRecord::Base
  belongs_to :person
end

class FootballTeam < ActiveRecord::Base
  #
end

class CricketTeam < ActiveRecord::Base
  #
end

class Friendship < ActiveRecord::Base
  belongs_to :person
  belongs_to :friend, :class_name => "Person"
  
  define_index do
    has person_id, friend_id
  end
end
