begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  if AdminSetting.table_exists? && !AdminSetting.first
    settings = AdminSetting.new(invite_from_queue_enabled: ArchiveConfig.INVITE_FROM_QUEUE_ENABLED,
          invite_from_queue_number: ArchiveConfig.INVITE_FROM_QUEUE_NUMBER,
          invite_from_queue_frequency: ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY,
          account_creation_enabled: ArchiveConfig.ACCOUNT_CREATION_ENABLED,
          days_to_purge_unactivated: ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED)
    settings.save(validate: false)
  end
rescue ActiveRecord::ConnectionNotEstablished
end
