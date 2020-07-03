begin
  # If we have no database, fall through to rescue
  ActiveRecord::Base.connection
  AdminSetting.default if AdminSetting.table_exists?
rescue ActiveRecord::ConnectionNotEstablished
end
