class CreateLastWranglingActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :last_wrangling_activities do |t|
      t.references :user,
                   foreign_key: true,
                   type: :integer,
                   null: false,
                   dependent: :destroy,
                   index: { unique: true }

      t.timestamp :performed_at,
                  null: false,
                  default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
