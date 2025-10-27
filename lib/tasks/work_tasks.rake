namespace :work do
  desc "Purge drafts created more than a month ago"
  task(:purge_old_drafts => :environment) do
    count = 0
    Work.unposted.where('works.created_at < ?', 1.month.ago).find_each do |work|
      begin
        work.destroy!
        count += 1
      rescue StandardError => e
        puts "The following error occurred while trying to destroy draft #{work.id}:"
        puts "#{e.class}: #{e.message}"
        puts e.backtrace
      end
    end
    puts "Unposted works (#{count}) created more than one month ago have been purged"
  end

  desc "create missing hit counters"
  task(:missing_stat_counters => :environment) do
    Work.find_each do |work|
      counter = work.stat_counter
      unless counter
        counter = StatCounter.create(:work => work, :hit_count => 1)
      end
    end
  end

  # Usage: rake work:reset_word_counts[en]
  desc "Reset word counts for works in the specified language"
  task(:reset_word_counts, [:lang] => :environment) do |_t, args|
    language = Language.find_by(short: args.lang)

    updated_works = "ALL"
    if language.nil?
      works = Work.all
    else
      works = Work.where(language: language)
      updated_works = language.short
    end

    print "Resetting word count for #{works.count} '#{updated_works}' works: "

    works.find_in_batches do |batch|
      batch.each do |work|
        work.chapters.each do |chapter|
          chapter.content_will_change!
          chapter.save
        end
        work.save
      end
      print(".") && STDOUT.flush
    end
    puts && STDOUT.flush
  end

  # Usage: rake work:reset_word_counts_before_date[YYYY-MM-DD]
  desc "Reset word counts for all works created before December 25, 2018"
  task(:reset_word_counts_before_date, [:date] => :environment) do |_t, args|

    if args.date.nil?
      puts "Please enter a date. Use format YYYY-MM-DD."
      exit 1
    end

    cutoff_date = Date.parse(args.date)
    works = Work.where('works.created_at < ?', cutoff_date)

    print "Resetting word count for #{works.count} works created before #{cutoff_date}: "

    works.find_in_batches do |batch|
      batch.each do |work|
        work.chapters.each do |chapter|
          chapter.content_will_change!
          chapter.save
        end
        work.save
      end
      print(".") && STDOUT.flush
    end
    puts && STDOUT.flush
  end
end
