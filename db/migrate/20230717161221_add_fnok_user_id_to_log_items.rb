class AddFnokUserIdToLogItems < ActiveRecord::Migration[6.1]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = LogItem.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=log_items \\
          --alter "ADD `fnok_user_id` int DEFAULT NULL,
                  ADD INDEX `index_log_items_on_fnok_user_id` (`fnok_user_id`),
                  ADD CONSTRAINT `fk_rails_6a47a753ee" FOREIGN KEY (`fnok_user_id`) REFERENCES `users` (`id`)" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_log_items_old`;
      PTOSC
    else
      add_column :log_items, :fnok_user_id, :integer, nullable: true, default: nil
      add_index :log_items, :fnok_user_id
      add_foreign_key :log_items, :users, column: :fnok_user_id
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = LogItem.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=log_items \\
          --alter "DROP FOREIGN KEY fk_rails_6a47a753ee,
                  DROP COLUMN `fnok_user_id`"\\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_log_items_old`;
      PTOSC
    else
      remove_column :log_items, :fnok_user_id
    end
  end
end
