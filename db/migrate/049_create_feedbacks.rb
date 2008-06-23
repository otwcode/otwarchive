class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
