namespace :comment do
  desc "Syncs the Comments.approved column to the new Comments.spam column"
  task(:sync_approved_to_spam, [:limit] => :environment) do |_t, args|
    # DB admin can pass in an optional integer for the limit
    limit = args&.limit&.to_i

    # success_count is used to provide status updates as the rake task is running.
    success_count = 0

    # Count is only used when a limit is provided. Otherwise, it is ignored.
    count = 0 if limit.present?

    # The approved and spam columns are inverse values of each other. If approved is true, then spam
    # should be false, and vice versa. Thus, only records where approved and spam values are the same need to be synced.
    Comment.where("(approved IS TRUE AND spam IS TRUE) OR (approved IS FALSE AND spam IS FALSE)")
           .find_in_batches do |batch|
      batch.each do |comment|
        if comment.approved == comment.spam # Guard clause: guards against
          # unnecessary updates to the db if the query returns comments that have already been synced.
          comment.update_attribute(:spam, !comment.approved)
          success_count += 1
        end

        if limit.present?
          # Provide verbose logging if limit is set
          puts "Updated comment #{comment.id} spam attribute to #{comment.spam}."
          # Break out of loop if limit is met or exceeded
          count += 1
          break if limit <= count
        end
      end
      # Provide periodic logging to monitor rake task progress.
      puts "#{success_count} comments synced."

      # Break out of loop if limit is met or exceeded
      break if limit.present? && limit <= count
    end

    puts "Task complete. #{success_count} comments successfully synced."
  end
end