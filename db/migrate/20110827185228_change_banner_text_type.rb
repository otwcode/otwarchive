class ChangeBannerTextType < ActiveRecord::Migration
  def self.up
    change_table :admin_settings do |t|
      t.change :banner_text, :text
    end
  end

  def self.down
    change_table :admin_settings do |t|
      t.change :banner_text, :string
    end
  end
end
