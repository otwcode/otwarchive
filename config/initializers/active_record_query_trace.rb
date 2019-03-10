if Rails.env.development?
  ActiveRecordQueryTrace.enabled = true
  # Optional: other gem config options go here
  ActiveRecordQueryTrace.ignore_cached_queries = true # Default is false.
  ActiveRecordQueryTrace.colorize = :light_purple            # Colorize in default color
end