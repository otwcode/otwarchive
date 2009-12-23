class AddFindsMissingIndexes < ActiveRecord::Migration
  def self.up
  
    # These indexes were found by searching for AR::Base finds on your application
    # It is strongly recommanded that you will consult a professional DBA about your infrastucture and implemntation before
    # changing your database in that matter.
    # There is a possibility that some of the indexes offered below is not required and can be removed and not added, if you require
    # further assistance with your rails application, database infrastructure or any other problem, visit:
    #
    # http://www.railsmentors.org
    # http://www.railstutor.org
    # http://guides.rubyonrails.org
  
    add_index :works, :imported_from_url
    add_index :invite_requests, :email
    add_index :languages, :short
    add_index :invitations, :token
    add_index :users, :activation_code
    add_index :users, :email
    add_index :roles, :authorizable_type
    add_index :roles, :name
  end

  def self.down
    remove_index :works, :imported_from_url
    remove_index :invite_requests, :email
    remove_index :languages, :short
    remove_index :invitations, :token
    remove_index :users, :activation_code
    remove_index :users, :email
    remove_index :roles, :authorizable_type
    remove_index :roles, :name
  end
end

