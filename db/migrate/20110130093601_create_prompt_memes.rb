class CreatePromptMemes < ActiveRecord::Migration
  def self.up
    create_table :prompt_memes do |t|
      t.references :prompt_restriction
      t.integer :request_restriction_id

      t.integer :requests_num_required, :null => false, :default => 1
      t.integer :requests_num_allowed, :null => false, :default => 1
      t.boolean :signup_open, :null => false, :default => false
      t.datetime :signups_open_at
      t.datetime :signups_close_at
      t.datetime :assignments_due_at
      t.datetime :works_reveal_at
      t.datetime :authors_reveal_at
      t.text :signup_instructions_general
      t.text :signup_instructions_requests
      t.string :request_url_label
      t.string :request_description_label
      t.string :time_zone
      t.integer :signup_instructions_general_sanitizer_version,  :limit => 2, :default => 0,     :null => false
      t.integer :signup_instructions_requests_sanitizer_version, :limit => 2, :default => 0,     :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :prompt_memes
  end
end
