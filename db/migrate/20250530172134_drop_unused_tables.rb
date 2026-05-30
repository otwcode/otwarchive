class DropUnusedTables < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        drop_table :work_links, if_exists: true
        drop_table :searches, if_exists: true
        drop_table :delayed_jobs, if_exists: true
      end

      dir.down do
        raise ActiveRecord::IrreversibleMigration
      end
    end
  end
end
