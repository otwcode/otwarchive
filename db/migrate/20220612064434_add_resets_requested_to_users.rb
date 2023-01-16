class AddResetsRequestedToUsers < ActiveRecord::Migration[6.0]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = User.connection.current_database

      puts <<~PTOSC
        Schema Change Command:
        pt-online-schema-change D=#{database},t=users \\
          --alter "ADD resets_requested int DEFAULT 0 NOT NULL,
                   CREATE INDEX index_users_on_resets_requested (resets_requested)" \\
          --no-drop-old-table --no-check-unique-key-change \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute
      PTOSC
    else
      add_column :users, :resets_requested, :integer, default: 0, null: false
      add_index :users, :resets_requested
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = User.connection.current_database

      puts <<~PTOSC
        Schema Change Command:
        pt-online-schema-change D=#{database},t=users \\
          --alter "DROP INDEX index_users_on_resets_requested,
                   DROP COLUMN resets_requested" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute
      PTOSC
    else
      remove_index :users, :resets_requested
      remove_column :users, :resets_requested
    end
  end
end