ActiveRecord::ConnectionAdapters::SchemaStatements.send(:include, RedHillConsulting::TransactionalMigrations::ActiveRecord::ConnectionAdapters::SchemaStatements)
ActiveRecord::Migration.send(:include, RedHillConsulting::TransactionalMigrations::ActiveRecord::Migration)
