PumaWorkerKiller.config do |config|
  config.rolling_restart_frequency = ArchiveConfig.PUMA_ROLLING_RESTART_FREQUENCY + rand(ArchiveConfig.PUMA_ROLLING_RESTART_SPLAY)
end
