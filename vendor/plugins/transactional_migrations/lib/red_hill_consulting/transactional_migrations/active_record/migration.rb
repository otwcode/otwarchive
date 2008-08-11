module RedHillConsulting::TransactionalMigrations::ActiveRecord
  module Migration
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def self.extended(base)
        class << base
          alias_method_chain :migrate, :transactional_migrations
        end
      end

      def migrate_with_transactional_migrations(direction)
        ActiveRecord::Base.transaction { migrate_without_transactional_migrations(direction) }
      end
    end
  end
end
