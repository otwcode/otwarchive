class AddOriginalCreatorsToWork < ActiveRecord::Migration[6.0]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = User.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=works \\
          --alter "ADD COLUMN original_creator_ids TEXT, ADD COLUMN orphaned_at DATETIME" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_works_old`;
      PTOSC
    else
      add_column :works, :original_creator_ids, :text
      add_column :works, :orphaned_at, :datetime
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = User.connection.current_database

      puts <<~PTOSC
        Schema Change Command:
      
        pt-online-schema-change D=#{database},t=works \\
          --alter "DROP COLUMN original_creator_ids, DROP COLUMN orphaned_at" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute
      
        Table Deletion Command:
      
        DROP TABLE IF EXISTS `#{database}`.`_works_old`;
      PTOSC
    else
      remove_column :works, :original_creator_ids
      remove_column :works, :orphaned_at
    end
  end
end
