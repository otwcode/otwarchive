namespace :work_import_urls do
  desc "Backfill work_import_urls from works.imported_from_url (run BEFORE removing the column)"
  task backfill: :environment do
    batch_size = 1000

    # Query the column directly since this task runs before column removal
    scope = Work.where("imported_from_url IS NOT NULL AND imported_from_url != ''")
    total = scope.count
    processed = 0

    puts "Backfilling #{total} work_import_urls records..."

    scope.find_each(batch_size: batch_size) do |work|
      next if WorkImportUrl.exists?(work_id: work.id)

      url = work.read_attribute(:imported_from_url)
      WorkImportUrl.create!(
        work: work,
        url: url
      )

      processed += 1
      puts "Processed #{processed}/#{total}" if (processed % batch_size).zero?
    end

    puts "Done! Backfilled #{processed} records."
  end
end
