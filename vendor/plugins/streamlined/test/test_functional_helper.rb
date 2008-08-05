base = File.dirname(__FILE__)

require File.join(base, 'test_helper')
require File.join(base, "lib", 'ar_helper')
require 'active_record/fixtures'

$: << File.join(base,"fixtures")
# getting messy: Poet needed by Poem
require "poet"

# Require sample fixtures, models, and UI classes
# .sort.each added to ensure that the list is sorted and person.rb is "required"
# before person_ui.rb; person_ui.rb references the Person class.
Dir.glob("#{base}/fixtures/*.rb").sort.each do |file|
  require File.basename(file, ".*")
end

EXPECTED_USERS = [/\d[[:punct:]]Justin[[:punct:]]Gehtland/, /\d[[:punct:]]Stu[[:punct:]]Halloway/,/\d[[:punct:]]Jason[[:punct:]]Rudolph/,/\d[[:punct:]]Glenn[[:punct:]]Vanderburg/]
EXPECTED_USERS_IN_XML = [/<Person>\n.*<last_name>Gehtland<\/last_name>\n.*<full_name>Justin Gehtland<\/full_name>\n.*<\/Person>/,
  /<Person>\n.*<last_name>Halloway<\/last_name>\n.*<full_name>Stu Halloway<\/full_name>\n.*<\/Person>/,
  /<Person>\n.*<last_name>Rudolph<\/last_name>\n.*<full_name>Jason Rudolph<\/full_name>\n.*<\/Person>/,
  /<Person>\n.*<last_name>Vanderburg<\/last_name>\n.*<full_name>Glenn Vanderburg<\/full_name>\n.*<\/Person>/]
EXPECTED_USERS_IN_XML_FIRST_LAST = [/<Person>\n.*<first_name>Justin<\/first_name>\n.*<last_name>Gehtland<\/last_name>\n.*<full_name>Justin Gehtland<\/full_name>\n.*<\/Person>/,
  /<Person>\n.*<first_name>Stu<\/first_name>\n.*<last_name>Halloway<\/last_name>\n.*<full_name>Stu Halloway<\/full_name>\n.*<\/Person>/,
  /<Person>\n.*<first_name>Jason<\/first_name>\n.*<last_name>Rudolph<\/last_name>\n.*<full_name>Jason Rudolph<\/full_name>\n.*<\/Person>/,
  /<Person>\n.*<first_name>Glenn<\/first_name>\n.*<last_name>Vanderburg<\/last_name>\n.*<full_name>Glenn Vanderburg<\/full_name>\n.*<\/Person>/]                           
EXPECTED_USERS_IN_JSON = [/\{id: \"1\", first_name: \"Justin\", last_name: \"Gehtland\"\}/,
  /\{id: \"2\", first_name: \"Stu\", last_name: \"Halloway\"\}/,
  /\{id: \"3\", first_name: \"Jason\", last_name: \"Rudolph\"\}/,
  /\{id: \"4\", first_name: \"Glenn\", last_name: \"Vanderburg\"\}/]
EXPECTED_USERS_IN_JSON_EDGE = [/\{\"id\": 1, \"first_name\": \"Justin\", \"last_name\": \"Gehtland\"\}/,
  /\{\"id\": 2, \"first_name\": \"Stu\", \"last_name\": \"Halloway\"\}/,
  /\{\"id\": 3, \"first_name\": \"Jason\", \"last_name\": \"Rudolph\"\}/,
  /\{\"id\": 4, \"first_name\": \"Glenn\", \"last_name\": \"Vanderburg\"\}/]
EXPECTED_USERS_IN_YAML = [/id: 1\n.* first_name: Justin\n.* last_name: Gehtland/,
  /id: 2\n.* first_name: Stu\n.* last_name: Halloway/,
  /id: 3\n.* first_name: Jason\n.* last_name: Rudolph/,
  /id: 4\n.* first_name: Glenn\n.* last_name: Vanderburg/]
  
class Test::Unit::TestCase
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
  self.use_instantiated_fixtures = false
  self.use_transactional_fixtures = true

  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(self.class.fixture_path, table_names, {}, &block)
  end

  def setup_routes
    ActionController::Routing::Routes.draw do |map|
      map.connect ':controller/:action/:id.:format'
      map.connect ':controller/:action/:id'
    end    
    ActionController::Routing.use_controllers! %w(people)
  end
  
  def stock_controller_and_view(controller = PeopleController)
    setup_routes
    @controller = controller.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @item = Struct.new(:id).new(1)
    get 'index'
    @view = @response.template
  end

end

unless ActionController::Base.respond_to?(:view_paths=)
  # Monkey patching ActionView. This sucks, but I got tired of trying to
  # find how to get the base_path set.
  class ActionView::Base
    def initialize(base_path = nil, assigns_for_first_render = {}, controller = nil)#:nodoc:
      @base_path, @assigns = base_path, assigns_for_first_render
      @assigns_added = nil
      @controller = controller
      @logger = controller && controller.logger 
      @base_path = File.join(RAILS_ROOT, "app/views")
    end
  end
end

def assert_matches_all(expecteds, actual)
  expecteds.each do |reg|
    assert_match(reg, actual)
  end
end

