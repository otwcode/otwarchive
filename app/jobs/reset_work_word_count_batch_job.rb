class ResetWorkWordCountBatchJob < ApplicationJob
  queue_as :low_priority

  def perform(batch, batch_number = nil, total_batches = nil)
    if batch_number && total_batches
      puts "Starting batch #{batch_number} of #{total_batches} (#{batch.size} works)"
    else
      puts "Starting batch (#{batch.size} works)"
    end

    Work.where(id: batch).find_each do |work|
      work.chapters.each do |chapter|
        chapter.content_will_change!
        chapter.save
      end
      work.save
    end

    if batch_number && total_batches
      puts "Finished batch #{batch_number}/#{total_batches}"
    else
      puts "Finished batch (#{batch.size} works)"
    end
  end
end