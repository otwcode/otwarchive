class RemoveEditEmailsAndPlainTextSkinFromPreferences < ActiveRecord::Migration[6.1]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = Preference.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=preferences \\
          --alter "DROP COLUMN edit_emails_off,
                   DROP COLUMN plain_text_skin" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_preferences_old`;
      PTOSC
    else
      remove_column :preferences, :edit_emails_off
      remove_column :preferences, :plain_text_skin
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = Preference.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=preferences \\
          --alter "ADD COLUMN edit_emails_off BOOLEAN NOT NULL DEFAULT 0,
                   ADD COLUMN plain_text_skin BOOLEAN NOT NULL DEFAULT 0" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_preferences_old`;
      PTOSC
    else
      add_column :preferences, :edit_emails_off, :boolean, default: false, null: false
      add_column :preferences, :plain_text_skin, :boolean, default: false, null: false
    end
  end
end
