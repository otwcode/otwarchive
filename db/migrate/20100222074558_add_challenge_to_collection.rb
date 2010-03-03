class AddChallengeToCollection < ActiveRecord::Migration
  def self.up
    change_table :collections do |t|
      t.references :challenge, :polymorphic => true
    end
  end

  def self.down
    remove_column :collections, :challenge_id
    remove_column :collections, :challenge_type    
  end
end
