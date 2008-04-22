ENV['RAILS_ENV'] ||= 'sqlite3'
require File.dirname(__FILE__) + '/rails_root/config/environment.rb'
 
# Load the testing framework
require 'test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }
 
# Run the migrations
ActiveRecord::Migrator.migrate("#{RAILS_ROOT}/db/migrate")
 
# Setup the fixtures path
Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)
 
class Test::Unit::TestCase #:nodoc:
  
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  protected
    def rfc2822_valid_addresses
      ['"Abc\@def"@example.com',
      '"Fred Bloggs"@example.com',
      '"Joe\\\\Blow"@example.com',
      '"Abc@def"@example.com',
      'customer/department=shipping@example.com',
      '$A12345@example.com',
      '!def!xyz%abc@example.com',
      '_somename@example.com',
      'ice.cream@isfun.co.uk',
      '"But I can not eat it because I am lactose intolerant!"@evildairy.on.ca']
    end
    
    def well_formed_addresses
      ['itsme@heycarsten.com',
      'steve_jobs@apple.com',
      'SomeoneNice@SomePlace.com',
      'joe.blow@domain.co.uk',
      'joe.blow_2@web-site.net',
      'c00ki3@m0nst3r.org',
      'test+heycarsten@gmail.com']
    end
    
    def malformed_addresses
      ['$#@%#@$%@#$%@#$%',
      'fake',
      'Do.Not.work',
      'nobody@',
      '@',
      '@noWhere.com',
      'hi*mom@%#+.&',
      '#$%^&$',
      'sdf%^%@\'d.Com',
      'babyJesus@|cry.org',
      'hampton_smells_like_haml@.info']
    end
    
    def nonexistant_addresses
      ['mynameis@slim.sha.dy',
      'butidont@reallylike.rap',
      'your_mother_was@hamster.and',
      'your_father_smells@of-elder-berr.ies']
    end
    
    def real_addresses
      %w[ itsme@heycarsten.com
      steve@apple.com
      pete@unspace.ca
      heycarsten@gmail.com ]
    end
  
end