class AddCoveredAtToChallengeAssignment < ActiveRecord::Migration
  def self.up
    add_column :challenge_assignments, :covered_at, :datetime
  end

  def self.down
    remove_column :challenge_assignments, :covered_at
  end
end
