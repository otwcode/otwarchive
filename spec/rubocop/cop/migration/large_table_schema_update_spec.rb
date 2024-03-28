# frozen_string_literal: true

require "rubocop_spec_helper"
require_relative "../../../../rubocop/cop/migration/large_table_schema_update"

describe RuboCop::Cop::Migration::LargeTableSchemaUpdate do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new("Migration/LargeTableSchemaUpdate" => { "Tables" => ["users"] }) }

  context "when running on a migration file" do
    before do
      allow(cop).to receive(:in_migration?).and_return(true)
    end

    context "when modifying a large table" do
      it "registers an offense if Departure is not used" do
        expect_offense(<<~RUBY)
          class FakeMigration < ActiveRecord::Migration[6.1]
            def change
              add_column :users, :foo, :boolean, default: false, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use departure to change the schema of large table `users`
            end
          end
        RUBY
      end

      it "does not register an offense if Departure is used" do
        expect_no_offenses(<<~RUBY)
          class FakeMigration < ActiveRecord::Migration[6.1]
            uses_departure! if Rails.env.staging? || Rails.env.production?

            def change
              add_column :users, :foo, :boolean, default: false, null: false
            end
          end
        RUBY
      end
    end

    context "when modifying a small table" do
      it "does not register an offense if Departure is not used" do
        expect_no_offenses(<<~RUBY)
          class FakeMigration < ActiveRecord::Migration[6.1]
            def change
              add_column :small, :foo, :boolean, default: false, null: false
            end
          end
        RUBY
      end
    end
  end
end
