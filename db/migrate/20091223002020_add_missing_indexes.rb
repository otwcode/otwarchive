class AddMissingIndexes < ActiveRecord::Migration
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

    
    add_index :collections, :parent_id
    add_index :comments, :pseud_id
    add_index :serial_works, :work_id
    add_index :serial_works, :series_id
    add_index :locales, :language_id
    add_index :collection_preferences, :collection_id
    add_index :inbox_comments, :feedback_comment_id
    add_index :tags, [:id, :type]
    add_index :tags, :fandom_id
    add_index :related_works, [:parent_id, :parent_type]
    add_index :related_works, :work_id
    add_index :user_invite_requests, :user_id
    add_index :works, :language_id
    add_index :log_items, :admin_id
    add_index :log_items, :role_id
    add_index :roles_users, [:role_id, :user_id]
    add_index :roles_users, [:user_id, :role_id]
    add_index :invitations, [:invitee_id, :invitee_type]
    add_index :invitations, :external_author_id
    add_index :invitations, [:creator_id, :creator_type]
    add_index :external_authors, :user_id
    add_index :external_creatorships, [:creation_id, :creation_type]
    add_index :external_creatorships, :external_author_name_id
    add_index :external_creatorships, :archivist_id
    add_index :roles, [:authorizable_id, :authorizable_type]
    add_index :readings, :work_id
    add_index :readings, :user_id
    add_index :external_author_names, :external_author_id
    add_index :admin_settings, :last_updated_by
    add_index :translation_notes, :locale_id
    add_index :translation_notes, :user_id
  end
  
  def self.down
    remove_index :collections, :parent_id
    remove_index :comments, :pseud_id
    remove_index :serial_works, :work_id
    remove_index :serial_works, :series_id
    remove_index :locales, :language_id
    remove_index :collection_preferences, :collection_id
    remove_index :inbox_comments, :feedback_comment_id
    remove_index :tags, :column => [:id, :type]
    remove_index :tags, :fandom_id
    remove_index :related_works, :column => [:parent_id, :parent_type]
    remove_index :related_works, :work_id
    remove_index :user_invite_requests, :user_id
    remove_index :works, :language_id
    remove_index :log_items, :admin_id
    remove_index :log_items, :role_id
    remove_index :roles_users, :column => [:role_id, :user_id]
    remove_index :roles_users, :column => [:user_id, :role_id]
    remove_index :invitations, :column => [:invitee_id, :invitee_type]
    remove_index :invitations, :external_author_id
    remove_index :invitations, :column => [:creator_id, :creator_type]
    remove_index :external_authors, :user_id
    remove_index :external_creatorships, :column => [:creation_id, :creation_type]
    remove_index :external_creatorships, :external_author_name_id
    remove_index :external_creatorships, :archivist_id
    remove_index :roles, :column => [:authorizable_id, :authorizable_type]
    remove_index :readings, :work_id
    remove_index :readings, :user_id
    remove_index :external_author_names, :external_author_id
    remove_index :admin_settings, :last_updated_by
    remove_index :translation_notes, :locale_id
    remove_index :translation_notes, :user_id
  end
end
