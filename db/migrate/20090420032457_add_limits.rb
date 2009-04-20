class AddLimits < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE common_taggings modify filterable_type varchar(100);'
    execute 'ALTER TABLE creatorships modify creation_type varchar(100);'
    execute 'ALTER TABLE tag_categories modify name varchar(100);'
    execute 'ALTER TABLE taggings modify taggable_type varchar(100) default "";'
    execute 'ALTER TABLE taggings modify tagger_type varchar(100) default "";'
    execute 'ALTER TABLE tags modify name varchar(100) default "";'
    execute 'ALTER TABLE users modify identity_url varchar(191) default NULL;'
  end

  def self.down
  end
end
