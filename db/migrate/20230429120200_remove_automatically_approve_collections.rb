class RemoveAutomaticallyApproveCollections < ActiveRecord::Migration[6.0]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = Preference.connection.current_database

      puts <<~PTSOC
        Schema Change Command:
        
        pt-online-schema-change D=#{database},t=preferences \\
          --alter "DROP COLUMN automatically_approve_collections" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute
          
        Table Deletion Command:
        
        DROP TABLE IF EXISTS `#{database}`.`_preferences_old`;
      PTSOC
    else
      remove_column :preferences, :automatically_approve_collections
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = Preference.connection.current_database

      puts <<~PTSOC
        Schema Change Command:
        
        pt-online-schema-change D=#{database},t=preferences \\
          --alter "ADD COLUMN automatically_approve_collections BOOLEAN NOT NULL DEFAULT 0" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute
          
        Table Deletion Command:
        
        DROP TABLE IF EXISTS `#{database}`.`_preferences_old`;
      PTSOC
    else
      add_column :preferences, :automatically_approve_collections, :boolean, default: false, null: false
    end
  end
end
