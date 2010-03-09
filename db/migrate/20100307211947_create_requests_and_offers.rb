class CreateRequestsAndOffers < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :prompt_restriction_id, :integer
    add_column :prompts, :type, :string
    GiftExchange.reset_column_information
    Prompt.reset_column_information
    Prompt.all.each do |prompt|
      if prompt.offer
        prompt.type = "Offer"
      else
        prompt.type = "Request"
      end
      prompt.save
    end
    remove_column :prompts, :offer
  end
  
  def self.down
    add_column :prompts, :offer, :boolean, :null => false, :default => false
    Prompt.reset_column_information
    Prompt.all.each do |prompt|
      if prompt.type == "Offer"
        prompt.offer = true
      else
        prompt.offer = false
      end
      prompt.save
    end
    remove_column :prompts, :type
    remove_column :gift_exchanges, :prompt_restriction_id
  end
end
