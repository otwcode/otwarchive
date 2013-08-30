class RevertFilterTaggingsPrimaryKey < ActiveRecord::Migration
  def self.up
    # We want to handle this differently for staging/production due to the size of the table
    if Rails.env.development?
      execute "ALTER TABLE `filter_taggings` DROP INDEX `primary`, ADD PRIMARY KEY (`id`);"
    end
  end

  def self.down
    if Rails.env.development?
      execute "ALTER TABLE `filter_taggings` DROP INDEX `primary`, ADD PRIMARY KEY (`id`,`filter_id`);"
    end
  end
end

