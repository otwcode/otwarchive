class AddSignupSummaryGeneratedAtToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :signup_summary_generated_at, :datetime
  end

  def self.down
    remove_column :collections, :signup_summary_generated_at
  end
end
