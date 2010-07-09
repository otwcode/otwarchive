Given /^I have an AdminSetting$/ do
  unless AdminSetting.first
    settings = AdminSetting.new(
      :invite_from_queue_enabled => ArchiveConfig.INVITE_FROM_QUEUE_ENABLED,
      :invite_from_queue_number => ArchiveConfig.INVITE_FROM_QUEUE_NUMBER,
      :invite_from_queue_frequency => ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY,
      :account_creation_enabled => ArchiveConfig.ACCOUNT_CREATION_ENABLED,
      :days_to_purge_unactivated => ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED)
    settings.save(false)
  end
end

When /^the invite_from_queue_at is yesterday$/ do
  AdminSetting.first.update_attribute(:invite_from_queue_at, Time.now - 1.day)
end

When /^the check_queue rake task is run$/ do
  AdminSetting.check_queue
end
