require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/controller/crud_methods'
require 'streamlined/controller/filter_methods'

describe "Streamlined::Controller::CrudMethods" do
  include Streamlined::Controller::CrudMethods
  include Streamlined::Controller::FilterMethods
  attr_accessor :model, :model_ui, :streamlined_request_context
  delegates *Streamlined::Context::RequestContext::DELEGATES
  
  it "helper delegates are private" do
    assert_has_private_methods self, :pagination
  end
  
  it "default options" do
    @streamlined_request_context = Streamlined::Context::RequestContext.new
    @model_ui = Streamlined.ui_for(Person)
    @model_ui.default_order_options('first_name ASC')
    assert_equal({:order => 'first_name ASC'}, order_options)
  end
  
  it "no options" do
    @streamlined_request_context = Streamlined::Context::RequestContext.new
    @model_ui = Streamlined.ui_for(Author)
    assert_equal({}, order_options)
  end
  
  it "ar options" do
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:sort_order=>"ASC", :sort_column=>"first_name")
    self.model = Person
    assert_equal({:order=>"first_name ASC"}, order_options)
  end

  # TODO: non ar_options should go away
  it "non ar options" do
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:sort_order=>"ASC", :sort_column=>"widget")
    self.model = Person
    # assert_equal({:order=>"widget ASC"}, order_options)
    assert_equal({:dir=>"ASC", :non_ar_column=>"widget"}, order_options)
  end
  
  it "filter options with no filter" do
    @streamlined_request_context = Streamlined::Context::RequestContext.new
    @model_ui = Streamlined.ui_for(Author)
    assert_equal({}, filter_options)
  end

  it "filter options with simple filter" do
    str = "data"
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:filter=>"#{str}")
    @model_ui = Streamlined.ui_for(Person)
    #{ActiveRecord::Base.connection.quote('%value%')}
    assert_equal({:conditions=>"people.first_name LIKE #{ActiveRecord::Base.connection.quote('%data%')} OR people.last_name LIKE #{ActiveRecord::Base.connection.quote('%data%')}", :include=>[]}, filter_options)
  end
  
  def filter_setup(conditions_string)
    @controller = PeopleController.new
    # Took a while to find this, setting layout=false was not good enough
    class <<@controller
      def active_layout
        false
      end
    end
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.send :initialize_template_class, @response
    @controller.send :assign_shortcuts, @request, @response
    
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:advanced_filter=>"#{conditions_string}")
    @model_ui = Streamlined.ui_for(Person)
  end

  it "filter options with advanced filter expired" do
    str = "data"
    conditions_string = "people.first_name like ?,%#{str}%"

    filter_setup(conditions_string)
    session[:num_filters] = nil
    assert_equal({}, filter_options)
  end

  it "filter options with advanced filter" do
    str = "data"
    conditions_string = "people.first_name like ?,%#{str}%"
    conditions        = ["people.first_name like ?", "%#{str}%"]

    filter_setup(conditions_string)
    session[:num_filters] = 1
    assert_equal({:conditions=>conditions}, filter_options)
  end

  it "filter options with advanced filter and include" do
    str = "data"
    conditions_string = "people.first_name like ?,%#{str}%"
    conditions        = ["people.first_name like ?", "%#{str}%"]

    filter_setup(conditions_string)

    session[:num_filters] = 1
    includes = ["people", "others"]
    session[:include] = includes

    assert_equal({:conditions=>conditions, :include=>includes}, filter_options)
  end

  it "filter options with advanced filter with nil" do
    str = "data"
    conditions_string = "people.first_name like ? and people.last_name is ?,%#{str}%,nil"
    conditions        = ["people.first_name like ? and people.last_name is ?", "%#{str}%", nil]

    filter_setup(conditions_string)

    session[:num_filters] = 1
    assert_equal({:conditions=>conditions}, filter_options)
  end

end
