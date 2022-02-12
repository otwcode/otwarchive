namespace :User do
  desc "Backfill renamed_at for existing users"
  task(add_renamed_at_from_log: :environment) do
    total_users = User.all.size
    total_batches = (total_users + 999) / 1000
    puts "Updating #{total_users} users in #{total_batches} batches"

    User.find_in_batches.with_index do |batch, index|
      batch.each do |user|
        renamed_at_from_log = user.log_items.where(action: ArchiveConfig.ACTION_RENAME).last&.created_at
        next unless renamed_at_from_log

        user.update_column(:renamed_at, renamed_at_from_log)
      end

      batch_number = index + 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"
      puts(progress_msg) && STDOUT.flush
    end
    puts && STDOUT.flush
  end
end
