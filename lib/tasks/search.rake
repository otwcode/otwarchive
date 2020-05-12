# frozen_string_literal: true

namespace :search do
  BATCH_SIZE = 1000

  desc 'Reindex tags'
  task(index_tags: :environment) do
    TagIndexer.index_all
  end
  desc 'Reindex pseuds'
  task(index_pseuds: :environment) do
    PseudIndexer.index_all
  end
  desc 'Reindex works'
  task(index_works: :environment) do
    WorkIndexer.index_all
  end
  desc 'Reindex bookmarks'
  task(index_bookmarks: :environment) do
    BookmarkIndexer.index_all
  end
  desc 'Reindex all'
  task timed_all: %i[timed_works timed_tags timed_pseud timed_bookmarks] do
  end
  desc 'Reindex bookmarks'
  task timed_bookmarks: :environment do
    time = ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
    ExternalWork.where("external_works.updated_at >  #{time}").select(:id).find_in_batches(batch_size: BATCH_SIZE) do |group|
      AsyncIndexer.new(BookmarkedExternalWorkIndexer, :world).enqueue_ids(group.map(&:id))
    end
    Series.where("series.updated_at >  #{time}").select(:id).find_in_batches(batch_size: BATCH_SIZE) do |group|
      AsyncIndexer.new(BookmarkedSeriesIndexer, :world).enqueue_ids(group.map(&:id))
    end
    Work.includes(:stat_counter).where('stat_counters.bookmarks_count > 0').references(:stat_counters).where("works.revised_at >  #{time}").select(:id).find_in_batches(batch_size: BATCH_SIZE) do |group|
      AsyncIndexer.new(TagIndexer, :world).enqueue_ids(group.map(&:id))
    end
  end
  desc 'Reindex works'
  task timed_works: :environment do
    time = ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
    Work.where("works.revised_at >  #{time}").select(:id).find_in_batches(batch_size: BATCH_SIZE) do |group|
      AsyncIndexer.new(WorkIndexer, :world).enqueue_ids(group.map(&:id))
    end
  end
  desc 'Reindex tags'
  task timed_tags: :environment  do
    time = ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
    Tag.where("tags.updated_at >  #{time}").select(:id).find_in_batches(batch_size: BATCH_SIZE) do |group|
      AsyncIndexer.new(TagIndexer, :world).enqueue_ids(group.map(&:id))
    end
  end
  desc 'Reindex psueds'
  task timed_pseud: :environment do
    time = ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
    Pseud.where("pseuds.updated_at >  #{time}").select(:id).find_in_batches(batch_size: BATCH_SIZE) do |group|
      AsyncIndexer.new(PseudIndexer, :world).enqueue_ids(group.map(&:id))
    end
  end

  desc "Run tasks enqueued to the world queue by IndexQueue."
  task run_world_index_queue: :environment do
    ScheduledReindexJob::MAIN_CLASSES.each do |klass|
      IndexQueue.from_class_and_label(klass, :world).run
    end
  end
end
