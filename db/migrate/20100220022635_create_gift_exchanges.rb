class CreateGiftExchanges < ActiveRecord::Migration
  def self.up
    create_table :gift_exchanges do |t|
      t.references :prompt_restriction
      t.integer :offer_restriction_id

      t.integer :prompts_num_required, :null => false, :default => 1
      t.integer :offers_num_required, :null => false, :default => 1
      t.integer :prompts_num_allowed, :null => false, :default => 1
      t.integer :offers_num_allowed, :null => false, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :gift_exchanges
  end
end
