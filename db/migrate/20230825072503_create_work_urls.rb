class CreateWorkUrls < ActiveRecord::Migration[6.1]
  def change
    create_table :work_urls do |t|
      t.string :formatted_url, index: true
      t.string :formatting_method
      t.references :work, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
