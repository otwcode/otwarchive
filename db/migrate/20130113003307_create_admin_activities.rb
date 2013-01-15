class CreateAdminActivities < ActiveRecord::Migration
  def self.up
    create_table :admin_activities do |t|
      t.references :admin
      t.integer :target_id
      t.string :target_type
      t.string :action
      t.text :summary
      t.integer :summary_sanitizer_version, :limit => 2, :default => 0, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_activities
  end
end
