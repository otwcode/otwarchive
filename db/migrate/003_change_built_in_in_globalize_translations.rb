class ChangeBuiltInInGlobalizeTranslations < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE globalize_translations ALTER COLUMN built_in DROP DEFAULT'
  end

  def self.down
    execute 'ALTER TABLE globalize_translations ALTER COLUMN built_in SET DEFAULT 1'
  end
end
