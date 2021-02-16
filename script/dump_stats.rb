# 1. Run this script on production as follows:
#      RAILS_ENV=production bundle exec rails r script/dump_stats.rb
# frozen_string_literal: true

CSV.open(ENV['WORKS_FILENAME'] || '/tmp/works.csv', "wb", :write_headers => true, \
         :headers => ["created_at", "language", "restricted", "complete", "word_count", "tags"]) do |work_csv|
  CSV.open(ENV['STATS_FILENAME'] || '/tmp/stats.csv', "wb", :write_headers => true, \
         :headers => ["count_of_days", "to,from", "day_of_week", "tag_type", "tag_ids", "count"]) do |stats_csv|
    first_time = Work.first.created_at
    days = 1
    end_date = DateTime.now.beginning_of_day
    start_date = end_date - 1.day
    loop do
      w = Work.where(posted: true, hidden_by_admin: false, in_unrevealed_collection: false, created_at: start_date..end_date)
      fandoms = Hash.new(0)
      categories = Hash.new(0)
      ratings = Hash.new(0)
      warnings = Hash.new(0)
      characters = Hash.new(0)
      relationships = Hash.new(0)
      freeforms = Hash.new(0)
      warnings_multi = Hash.new(0)
      categories_multi = Hash.new(0)
      puts "#{days},#{end_date},#{start_date},#{w.count}"
      w.each do |work|
        work_csv << [days,start_date.strftime('%F'), work&.language&.short, work&.restricted, work&.complete, \
                work&.word_count, work&.tags&.pluck(:id)&.join('+')]
        next unless ENV['QUICK'].nil?

        warnings_multi[work&.archive_warnings&.pluck(:id)&.sort&.join('+')] += 1
        categories_multi[work&.category_ids&.sort&.join('+')] += 1
        work&.fandoms&.pluck(:id)&.each do |id|
          fandoms [id] += 1
        end
        work&.ratings&.pluck(:id)&.each do |id|
          ratings [id] += 1
        end
        work&.archive_warnings&.pluck(:id)&.each do |id|
          warnings [id] += 1
        end
        work&.characters&.pluck(:id)&.each do |id|
          characters [id] += 1
        end
        work&.freeforms&.pluck(:id)&.each do |id|
          freeforms [id] += 1
        end
        work&.taggings.select { |t| Tag.find(t.tagger_id).type == "Relationship" }.map { |t| Tag.find(t.tagger_id).id }&.each do |id|
          relationships [id] += 1
        end
        work&.taggings.select { |t| Tag.find(t.tagger_id).type == "Category" }.map { |t| Tag.find(t.tagger_id).id }&.each do |id|
          categories [id] += 1
        end
      end
      if ENV['QUICK'].nil?
        stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "works", "all_works", w.count]
        categories.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "category", id, value]
        end
        categories_multi.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "category_multi", id, value]
        end
        warnings.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "warning", id, value]
        end
        warnings_multi.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "warning_multi", id, value]
        end
        fandoms.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "fandom", id, value]
        end
        ratings.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "rating", id, value]
        end
        characters.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "characters", id, value]
        end
        freeforms.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "freeform", id, value]
        end
        relationships.each do |id, value|
          stats_csv << [days, end_date, start_date, start_date.strftime('%A'), "relationships", id, value]
        end
      end

      days += 1
      end_date = start_date
      start_date -= 1.day
      break if end_date < first_time
    end
  end
end
CSV.open(ENV['TAGS_FILENAME'] || '/tmp/stats.csv', "wb", :write_headers => true, \
         :headers => ["id", "type", "name", "canonical", "cached_count", "merger_id"]) do |tags_csv|
  Tag.find_in_batches do |batch|
    batch.each do |tag|
      tag_name = if tag.taggings_count_cache <= (ENV['TAGS_REDACTED_COUNT'] || 5) && !tag.canonical
                   "Redacted"
                 else
                   tag.name
                 end
      tags_csv << [tag.id, tag.type, tag_name, tag.canonical, tag.taggings_count_cache, tag.merger_id]
    end
  end
end