class CreateCreatorships < ActiveRecord::Migration
  def self.up
    create_table :creatorships do |t|
      t.references :creation, :polymorphic => true
      t.references :pseud

      t.timestamps
    end
  end

  def self.down
    drop_table :creatorships
  end
end
