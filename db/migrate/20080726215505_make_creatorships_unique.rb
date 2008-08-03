class MakeCreatorshipsUnique < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `creatorships` ADD UNIQUE `creation_id_creation_type_pseud_id` (`creation_id`, `creation_type`, `pseud_id`)"
  end

  def self.down
    execute "ALTER TABLE `creatorships` DROP INDEX `creation_id_creation_type_pseud_id`"
  end
end
