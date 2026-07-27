class ChangeGeneratedDownloadArgumentsToText < ActiveRecord::Migration[8.0]
  def up
    change_column :generated_downloads, :arguments, :text, null: false
  end

  def down
    change_column :generated_downloads, :arguments, :json, null: false
  end
end
