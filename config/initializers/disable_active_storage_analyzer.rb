# We don't want to fill up the queue with jobs that hammer the database
# (and extract metadata we don't use). Ref https://stackoverflow.com/a/74879360.
Rails.application.config.to_prepare do
  ActiveStorage::Attachment.skip_callback(:commit, :after, :analyze_blob_later)
end
