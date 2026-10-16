class ChangeUserAgentLimit < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    change_column :feedbacks, :user_agent, :string, limit: 500
    change_column :comments, :user_agent, :string, limit: 500
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reverted because it would result in a shorter character limit"
  end
end
