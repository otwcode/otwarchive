class CreateChallengeSignups < ActiveRecord::Migration
  def self.up
    create_table :challenge_signups do |t|
      t.references :collection
      t.references :pseud

      t.timestamps
    end
  end

  def self.down
    drop_table :challenge_signups
  end
end
