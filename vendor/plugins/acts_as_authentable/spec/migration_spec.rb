require File.dirname(__FILE__) + '/spec_helper'

MIGRATIONS = File.dirname(__FILE__) + '/resources/migrations/'

describe 'Migrating a fresh database' do

  it 'should create a people table' do
    migrate_up(1)
    person = Person.new
    person.attribute_names.should == %w(created_at name updated_at)
  end

  it 'should create authentable fields' do
    Person.acts_as_authentable
    migrate_up
    person = Person.new
    person.attribute_names.should == %w(created_at
                                        crypted_password
                                        login
                                        name
                                        remember_token
                                        remember_token_expires_at
                                        updated_at)
  end

  def migrate_up(version=nil)
    prepare_database
    ActiveRecord::Migrator.up(MIGRATIONS, version)
    Person.reset_column_information
  end
end

describe 'Migrating a populated database' do

  it 'should remove the authentable fields' do
    Person.acts_as_authentable
    migrate_down(1)
    person = Person.new
    person.attribute_names.should == %w(created_at name updated_at)
  end

  it 'should drop the people table' do
    migrate_down
    lambda do
      person = Person.new
    end.should raise_error(ActiveRecord::StatementInvalid)
  end

  def migrate_down(version=nil)
    prepare_database
    ActiveRecord::Migrator.up(MIGRATIONS)
    ActiveRecord::Migrator.down(MIGRATIONS, version)
    Person.reset_column_information
  end
end

private

  def prepare_database
    ActiveRecord::Base.connection.initialize_schema_information
    ActiveRecord::Base.connection.update "UPDATE schema_info SET version = 0"
    ActiveRecord::Base.connection.drop_table 'people' rescue nil
  end
