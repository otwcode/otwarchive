class ChangePreferenceAllowGiftsDefault < ActiveRecord::Migration[5.2]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = Preference.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=preferences \\
          --alter "ALTER allow_gifts SET DEFAULT 0" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_preferences_old`;
      PTOSC
    else
      change_column_default :preferences, :allow_gifts, from: true, to: false
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = Preference.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=preferences \\
          --alter "ALTER allow_gifts SET DEFAULT 1" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_preferences_old`;
      PTOSC
    else
      change_column_default :preferences, :allow_gifts, from: false, to: true
    end
  end
end
