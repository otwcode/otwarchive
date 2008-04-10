class CreateMetadatas < ActiveRecord::Migration
  def self.up
    create_table :metadatas do |t|
      t.string :title
      t.text :summary
      t.text :notes
      t.references :described
      t.string :described_type

      t.timestamps
    end
  end

  def self.down
    drop_table :metadatas
  end
end
