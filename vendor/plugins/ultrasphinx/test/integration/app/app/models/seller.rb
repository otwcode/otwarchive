class Seller < ActiveRecord::Base
  belongs_to :user  
  delegate :address, :to => :user
  
  is_indexed :fields => [
    {:field => 'company_name', :facet => true},
    {:field => 'mission_statement', :sortable => true},
    'created_at', 
    'capitalization', 
    'user_id'
  ]
  
  def name 
    company_name
  end
  
  def metadata
    "sfdkjl fsdjkl sdfjl fdsjk #{company_name} " * 5
  end  
end
