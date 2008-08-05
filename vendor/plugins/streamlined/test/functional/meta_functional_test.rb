require File.expand_path(File.join(File.dirname(__FILE__), '../test_functional_helper'))
require 'streamlined/controller'
require 'streamlined/ui'
require 'streamlined/functional_tests'

describe "MetaFunctional" do
  fixtures :people
  include Streamlined::FunctionalTests
  def setup
    setup_routes
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    self.model_class = Person
    self.relevance_crud_fixture = :justin
    self.form_fields = {:input=>[:first_name, :last_name]}
  end
end