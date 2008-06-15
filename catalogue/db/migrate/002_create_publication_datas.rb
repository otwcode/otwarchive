class CreatePublicationDatas < ActiveRecord::Migration
  def self.up
    create_table :publication_datas do |t|
      t.references :book
      t.string :publisher
      t.string :pagelength

      t.timestamps
    end
  end

  def self.down
    drop_table :publication_datas
  end
end
