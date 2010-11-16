class RemoveSignupSummaryGeneratedAtFromCollections < ActiveRecord::Migration

  def self.up
    remove_column :collections, :signup_summary_generated_at
  end

  def self.down
    add_column :collections, :signup_summary_generated_at, :datetime
  end

end
