class ChangeCssType < ActiveRecord::Migration[6.1]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = Skin.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=skins \\
          --alter "CHANGE COLUMN css css longtext" \\
          --no-drop-old-table --no-check-unique-key-change \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_skins_old`;
      PTOSC
    else
      change_column :skins, :css, :text, limit: 4_294_967_295
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = Skin.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=skins \\
          --alter "CHANGE COLUMN css css text" \\
          --no-drop-old-table --no-check-unique-key-change \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_skins_old`;
      PTOSC
    else
      change_column :skins, :css, :text
    end
  end
end
