class AddRealAnonymity < ActiveRecord::Migration
  def self.up
    # Add a setting that lets us enable/disable anonymous posting at a site-wide level
    add_column :admin_settings, :allow_anonymous_works,          :boolean, :null => false, :default => false
    add_column :works,          :transfer_to_anonymous,          :boolean, :null => false, :default => false
    create_table :work_key do |t|
      t.integer  "user_id"
      t.integer  "work_id"
      t.string   "pass_key"
    end
  end

  def self.down
    drop_table :work_key
    remove_column :admin_settings, :allow_anonymous_works
    remove_column :works,          :transfer_to_anonymous
  end
end
