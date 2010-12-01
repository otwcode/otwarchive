class CreateKudos < ActiveRecord::Migration
  def self.up
    create_table :kudos do |t|
      t.integer :pseud_id
      t.integer :commentable_id
      t.string :commentable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :kudos
  end
end
