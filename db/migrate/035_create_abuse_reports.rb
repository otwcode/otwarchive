class CreateAbuseReports < ActiveRecord::Migration
  def self.up
    create_table :abuse_reports do |t|
      t.string :email
      t.string :url
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :abuse_reports
  end
end
