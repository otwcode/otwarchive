# 1. Run this script on production as follows:
#      RAILS_ENV=production bundle exec rails r script/dump_stats.rb
# frozen_string_literal: true

work_output = File.open(ENV['WORKS_FILENAME'] || '/tmp/works.csv', 'w')
work_output.puts "Created_at,language,restricted,complete,word_count,tags\n"
if ENV['QUICK'].nil?
  stats_output = File.open(ENV['STATS_FILENAME'] || '/tmp/stats.csv', 'w')
  stats_output.puts "count_of_days,to,from,day_of_week,tag_type,tag_ids,count"
end
first_time = Work.first.created_at
days = 1
to = DateTime.now.beginning_of_day
from = to - 1.day
loop do
  w = Work.where(posted: true, created_at: from..to)
  fandoms = {}
  fandoms.default = 0
  categories = {}
  categories.default = 0
  ratings = {}
  ratings.default = 0
  warnings = {}
  warnings.default = 0
  characters = {}
  characters.default = 0
  relationships = {}
  relationships.default = 0
  freeforms = {}
  freeforms.default = 0
  warnings_multi = {}
  warnings_multi.default = 0
  categories_multi = {}
  categories_multi.default = 0
  w.each do |work|
    work_output.puts "#{work.created_at.strftime('%F')},#{work&.language&.short},#{work&.restricted},#{work&.complete},#{work&.word_count},#{work&.tags&.pluck(:id)&.join('+')}\n"
    next unless ENV['QUICK'].nil?

    warnings_multi[work&.warnings&.pluck(:id)&.sort&.join('+')] += 1
    categories_multi[work&.category_ids&.sort&.join('+')] += 1
    work&.fandoms&.pluck(:id)&.each do |id|
      fandoms [id] += 1
    end
    work&.ratings&.pluck(:id)&.each do |id|
      ratings [id] += 1
    end
    work&.warnings&.pluck(:id)&.each do |id|
      warnings [id] += 1
    end
    work&.characters&.pluck(:id)&.each do |id|
      characters [id] += 1
    end
    work&.freeforms&.pluck(:id)&.each do |id|
      freeforms [id] += 1
    end
    work&.relationship_ids&.each do |id|
      relationships [id] += 1
    end
    work&.category_ids&.each do |id|
      categories [id] += 1
    end
  end
  next unless ENV['QUICK'].nil?

  stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},works,all_works,#{w.count}"
  categories.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},category,#{id},#{value}"
  end
  categories_multi.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},category_multi,#{id},#{value}"
  end
  warnings.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},warning,#{id},#{value}"
  end
  warnings_multi.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},warning_multi,#{id},#{value}"
  end
  fandoms.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},fandom,#{id},#{value}"
  end
  ratings.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},rating,#{id},#{value}"
  end
  characters.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},characters,#{id},#{value}"
  end
  freeforms.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},freeform,#{id},#{value}"
  end
  relationships.each do |id, value|
    stats_output.puts "#{days},#{to},#{from},#{from.strftime('%A')},relationships,#{id},#{value}"
  end
  stats_output.flush

  days += 1
  to = from
  from -= 1.day
  break if to < first_time
end
work_output.close
stats_output.close unless ENV['QUICK'].nil?
tag_output = File.open(ENV['TAGS_FILENAME'] || '/tmp/tags.csv', 'w')
tag_output.puts "id,type,name,canonical,cached_count,adult,merger_id,unwrangleable\n"
Tag.find_in_batches do |batch|
  batch.each { |tag| tag_output.puts "#{tag.id},#{tag.type},#{tag.name},#{tag.canonical},#{tag.taggings_count_cache},#{tag.adult},#{tag.merger_id},#{tag.unwrangleable}\n" }
end
tag_output.close
