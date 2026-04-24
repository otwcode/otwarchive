class AddHideChapterNumberingToWorks < ActiveRecord::Migration[7.0]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_column :works, :hide_chapter_numbering, :boolean, default: false, null: false
  end
end
