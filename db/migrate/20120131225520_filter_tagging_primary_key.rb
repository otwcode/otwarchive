class FilterTaggingPrimaryKey < ActiveRecord::Migration
  def self.up
     # execute "ALTER TABLE `filter_taggings` DROP INDEX `primary`, ADD PRIMARY KEY (`id`,`filter_id`);"
#     execute "ALTER TABLE `filter_taggings` PARTITION BY KEY(`filter_id`) PARTITIONS 16;"
  end

  def self.down
#     execute "ALTER TABLE `filter_taggings` REMOVE PARTITIONING;"
     # execute "ALTER TABLE `filter_taggings` DROP INDEX `primary`, ADD PRIMARY KEY (`id`);"
  end
end
