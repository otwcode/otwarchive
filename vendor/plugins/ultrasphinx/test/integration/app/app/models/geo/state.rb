class Geo::State < ActiveRecord::Base
  has_many :addresses, :class_name => "Geo::Address"
  
  is_indexed :concatenate => [{:class_name => 'Geo::Address', :field => 'name', :as => 'address_name'}]
    #:fields => [{:field => 'abbreviation', :as => 'company_name'}],
end
