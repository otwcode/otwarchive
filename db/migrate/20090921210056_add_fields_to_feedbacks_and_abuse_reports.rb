class AddFieldsToFeedbacksAndAbuseReports < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :summary, :string
    add_column :feedbacks, :user_agent, :string
    add_column :feedbacks, :category, :string
    add_column :abuse_reports, :ip_address, :string
    add_column :abuse_reports, :category, :string
  end

  def self.down
    remove_column :feedbacks, :summary
    remove_column :feedbacks, :user_agent
    remove_column :feedbacks, :category
    remove_column :abuse_reports, :ip_address
    remove_column :abuse_reports, :category
  end
end
