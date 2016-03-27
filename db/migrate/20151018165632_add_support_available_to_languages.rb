class AddSupportAvailableToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :support_available, :boolean, default: false, null: false
  end
end
