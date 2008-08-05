require File.expand_path(File.join(File.dirname(__FILE__), '../test_functional_helper'))
require 'streamlined/controller'
require 'streamlined/ui'

describe "StreamlinedController" do
  fixtures :people

  def setup
    setup_routes
    Streamlined::ReloadableRegistry.reset
    PeopleController.filters.clear
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @per_page = 10
  end

  it "delegated methods are not routable" do
    action_methods = PeopleController.action_methods.map(&:to_sym)
    (action_methods & Streamlined::Context::RequestContext::DELEGATES).size.should == 0
  end
  
  it "should render index" do
    get :index
    assert_response :success
    assert_template generic_view("list")
    assert_equal @per_page, assigns(:options)[:per_page]
  end
  
  it "should render list" do
    get :list
    assert_response :success
    assert_template generic_view("list")
    assert_kind_of(ActionController::Pagination::Paginator, assigns(:streamlined_item_pages))
    assert_select("\#model_list", true, "should have generic id names for Ajax.Updater to replace")
    assert_select("\#people_list", false, "should not have model-specific id names")
    assert_select 'table#sl_list_people', true, 'table should have generic id for acceptance testing'
    assert_equal @per_page, assigns(:options)[:per_page]
  end

  def recording_log
    @controller.logger = Logger.new(recorder = StringIO.new)
    yield
    recorder.rewind
    recorder.read
  end
  
  it "should log warning if user presents an illegal column name" do
    (recording_log {
      get :list, :page_options=>{:sort_column=>"dangerous!", :sort_order=>"DESC"}
      assert_response :success
      assert_template generic_view("list")
    }).should =~ /^Possible intrusion attempt: Invalid sort column dangerous!$/
  end
  
  it "list with non ar column" do
    get :list, :page_options=>{:sort_column=>"full_name", :sort_order=>"DESC"}
    
    assert_response :success
    assert_template generic_view("list")
    assert_equal [people(:stu), people(:justin), people(:jason), people(:glenn)], assigns(:streamlined_items)
    assert_equal @per_page, assigns(:options)[:per_page]
  end
  
  it "list with filter" do
    get :list, :page_options=>{:filter=>"Justin"}
    assert_response :success
    assert_template generic_view("list")
    assert_equal @per_page, assigns(:options)[:per_page]
  end
  
  it "list with no pagination" do
    class <<@controller
      def pagination; false; end
    end
    get :list
    assert_equal [], assigns(:streamlined_item_pages)
    assert_equal nil, assigns(:options)[:per_page]
  end
  
  it "list with pagination options" do
    class <<@controller
      def pagination; { :per_page => 2 }; end
    end
    get :list
    assert_equal 2, assigns(:streamlined_items).size
    assert_equal 4, assigns(:streamlined_item_pages).item_count
    assert_equal 2, assigns(:streamlined_item_pages).page_count
  end
              
  it "should render an empty list" do   
    Person.delete_all
    get :list
    assert_response :success                          
    assert_select "tr[class=odd]", 1, "Should have exactly one tr with odd style only--no row/instance specific styles" do
      assert_select "div[class=sl_list_empty_message]"
    end
  end
  
  # TODO: set Content-Disposition? optional?
  # @headers["Content-Disposition"] = "attachment; filename=\"#{Inflector.tableize(model_name)}_#{Time.now.strftime('%Y%m%d')}.csv\""
  it "list xml" do
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :list, {:format => "xml", :full_download => "true"}
    assert_response :success
    assert_template nil
    assert_equal "application/xml", @response.content_type
    assert_select("people person", {:count=>4})
    assert_equal nil, assigns(:options)[:per_page]
  end

  it "should export csv with full download" do
    @request.env["HTTP_ACCEPT"] = "text/csv"
    get :list, {:format => "csv", :full_download => "true"}
    assert_response :success
    assert_template nil
    assert_equal "text/csv", @response.content_type
    assert_matches_all(EXPECTED_USERS, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end       

  it "should export csv for current page only" do
    @request.env["HTTP_ACCEPT"] = "text/csv"
    get :list, {:format => "csv", :full_download => "false"}
    assert_response :success
    assert_template nil
    assert_equal "text/csv", @response.content_type
    assert_matches_all(EXPECTED_USERS, @response.body)
    assert_equal @per_page, assigns(:options)[:per_page]
  end       

  it "should export csv with no header" do
    @request.env["HTTP_ACCEPT"] = "text/csv"
    get :list, {:format => "csv", :full_download => "true", :skip_header => "1"}
    assert_response :success
    assert_template nil
    assert_equal "text/csv", @response.content_type
    assert_matches_all(EXPECTED_USERS, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end       

  it "list csv with different separator" do
    @request.env["HTTP_ACCEPT"] = "text/csv"
    get :list, {:format => "csv", :full_download => "true", :separator => ";"}
    assert_response :success
    assert_template nil
    assert_equal "text/csv", @response.content_type
    assert_matches_all(EXPECTED_USERS, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end       

  it "list csv with no header and different separator" do
    @request.env["HTTP_ACCEPT"] = "text/csv"
    get :list, {:format => "csv", :full_download => "true", :skip_header => "1", :separator => ";"}
    assert_response :success
    assert_template nil
    assert_equal "text/csv", @response.content_type
    assert_matches_all(EXPECTED_USERS, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end       

  it "list json" do
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :list, {:format => "json", :full_download => "true"}
    assert_response :success
    assert_template nil
    assert_equal "application/json", @response.content_type   
    # JSON formatting changed between Rails 1.x and Rails 2
    # http://blog.codefront.net/2007/10/10/new-on-edge-rails-json-serialization-of-activerecord-objects-reaches-maturity/
    if Streamlined.edge_rails?
      assert_matches_all(EXPECTED_USERS_IN_JSON_EDGE, @response.body)
    else
      assert_matches_all(EXPECTED_USERS_IN_JSON, @response.body)
    end
    assert_nil assigns(:options)[:per_page]
  end       

  it "list yaml" do
    @request.env["HTTP_ACCEPT"] = "application/yaml"
    get :list, {:format => "yaml", :full_download => "true"}
    assert_response :success
    assert_template nil
    assert_equal "application/x-yaml", @response.content_type   
    assert_matches_all(EXPECTED_USERS_IN_YAML, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end       

  it "list enhanced xml" do
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :list, {:format => "EnhancedXML", :full_download => "true"}
    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/generic_views/list.rxml'
    assert_equal "application/xml", @response.content_type
    assert_select("people person", {:count=>4})
    assert_matches_all(EXPECTED_USERS_IN_XML_FIRST_LAST, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end

  it "list enhanced xml with selected columns" do
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :list, {:format => "EnhancedXML", :full_download => "true", :export_columns => {:full_name => "1", :last_name => "1"}}
    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/generic_views/list.rxml'
    assert_equal "application/xml", @response.content_type
    assert_select("people person", {:count=>4})
    assert_matches_all(EXPECTED_USERS_IN_XML, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end

  it "list enhanced xml to file" do
    @request.env["HTTP_ACCEPT"] = "text/xml"
    get :list, {:format => "EnhancedXMLToFile", :full_download => "true"}
    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/generic_views/list.rxml'
    assert_equal "text/xml", @response.content_type
    assert_select("people person", {:count=>4})
    assert_matches_all(EXPECTED_USERS_IN_XML_FIRST_LAST, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end

  it "list enhanced xml to file with selected columns" do
    @request.env["HTTP_ACCEPT"] = "text/xml"
    get :list, {:format => "EnhancedXMLToFile", :full_download => "true", :export_columns => {:full_name => "1", :last_name => "1"}}
    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/generic_views/list.rxml'
    assert_equal "text/xml", @response.content_type
    assert_select("people person", {:count=>4})

    check_for = '<?xml version="1.0" encoding="UTF-8"?>'
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")

    # The parameters appear in random orders so we check for one or the other
    check_for = '<?xml-stylesheet type="text/xsl" href="person.xsl"?>'
    check_for_2 = '<?xml-stylesheet href="person.xsl" type="text/xsl"?>'
    assert @response.body.to_s.index(check_for) || @response.body.to_s.index(check_for_2), "Did not find exact match for #{check_for} OR #{check_for_2} in #{@response.body}"  
    assert_matches_all(EXPECTED_USERS_IN_XML, @response.body)
    assert_equal nil, assigns(:options)[:per_page]
  end

  it "list xml stylesheet" do
    @request.env["HTTP_ACCEPT"] = "text/xml"
    get :list, {:format => "XMLStylesheet", :full_download => "true"}
    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/generic_views/stylesheet.rxml'
    assert_equal "text/xml", @response.content_type

    check_for = '<?xml version="1.0" encoding="UTF-8"?>'
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    
    # The parameters appear in random orders so we check for one or the other
    check_for = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">'
    check_for_2 = '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">'
    assert @response.body.to_s.index(check_for) || @response.body.to_s.index(check_for_2), "Did not find exact match for #{check_for} OR #{check_for_2} in #{@response.body}"  

    check_for = '
  <xsl:template match="/">
    <html>
      <body>
        <h2>People</h2>
        <table border="1">
          <tr bgcolor="#9acd32">
            <th align="left">
First name            </th>
            <th align="left">
Last name            </th>
            <th align="left">
Full name            </th>
          </tr>
          <xsl:for-each select="People/Person">
            <tr>
              <td>
                <xsl:value-of select="first_name"/>
              </td>
              <td>
                <xsl:value-of select="last_name"/>
              </td>
              <td>
                <xsl:value-of select="full_name"/>
              </td>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
'
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
  end
 
  it "list xml stylesheet with selected columns" do
    @request.env["HTTP_ACCEPT"] = "text/xml"
    get :list, {:format => "XMLStylesheet", :full_download => "true", :export_columns => {:full_name => "1", :last_name => "1"}}
    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/generic_views/stylesheet.rxml'
    assert_equal "text/xml", @response.content_type

    check_for = '<?xml version="1.0" encoding="UTF-8"?>'
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    
    # The parameters appear in random orders so we check for one or the other
    check_for = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">'
    check_for_2 = '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">'
    assert @response.body.to_s.index(check_for) || @response.body.to_s.index(check_for_2), "Did not find exact match for #{check_for} OR #{check_for_2} in #{@response.body}"  

    check_for = '
  <xsl:template match="/">
    <html>
      <body>
        <h2>People</h2>
        <table border="1">
          <tr bgcolor="#9acd32">
            <th align="left">
Last name            </th>
            <th align="left">
Full name            </th>
          </tr>
          <xsl:for-each select="People/Person">
            <tr>
              <td>
                <xsl:value-of select="last_name"/>
              </td>
              <td>
                <xsl:value-of select="full_name"/>
              </td>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
'
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
  end
 
  it "popup" do
    get :popup, :id => 1
    assert_equal people(:justin), assigns(:person)
    assert_template generic_view("_popup") 
  end
  
  it "show" do
    get :show, :id => 1
    assert_response :success
    assert_template generic_view("show")
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_select '#sl_field_person_first_name' do
      assert_select 'td.sl_show_label', 'First Name:'
      assert_select 'td.sl_show_value', 'Justin'
    end
    # TODO: refactor poke code so this becomes true
    # assert_unobtrusive_javascript
  end
  
  it "edit" do
    get :edit, :id => 1
    assert_generic_views_rendered "_form"
    assert_response :success
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_select '#sl_field_person_first_name' do
      assert_select 'td.sl_edit_label label', 'First Name'
      assert_select 'td.sl_edit_value input', ''  # test value='Justin'?
    end
  end

  # This is a very ugly workaround to verify that specific views were rendered
  # Currently relies on a variable set in convert_partial_options. Other 
  # render methods might also need to set this variable to take advantage of 
  # this assertion.
  def assert_generic_views_rendered(*views)
    generic_views = @response.template.generic_views_rendered.map{|v| File.basename(v,".*")}    
    views.each do |view|
      assert(generic_views.member?(view),
             "Should have rendered generic view #{view}, rendered generic views #{generic_views.inspect}")
    end
  end
  
  it "new" do
    get :new
    assert_generic_views_rendered "_form"
    assert_response :success
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_select '#sl_field_person_first_name' do
      assert_select 'td.sl_edit_label label', 'First Name'
      assert_select 'td.sl_edit_value input', ''
    end
  end
  
  it "create xhr" do
    assert_difference(Person, :count) do
      xhr :post, :create, :person => {:first_name=>'Another', :last_name=>'Person'}
      assert_response :success
    end
  end

  it "create" do
    assert_difference(Person, :count) do
      post :create, :person => {:first_name=>'Another', :last_name=>'Person'}
      assert_response :redirect
      assert_redirected_to :action => 'list'
    end
  end
    
  it "quick add uses correct form field labels" do
    Streamlined.ui_for("Poet")
    xhr :get, :quick_add, :select_id => "foo", :model_class_name => "Poet"
    assert_response :success
    assert_template "quick_add.rhtml"
    assert_match %r{<label for="poet_first_name">First Name</label>}, @response.body
    assert_match %r{<label for="poet_last_name">Last Name</label>}, @response.body
  end

  it "should have an accessible instance" do
    # This would fail if it was private
    @controller.access_instance
    
    get :show_special, :id => 1
    assert_response :success
    assert_equal people(:justin), assigns(:person)    
    assert_equal people(:justin), assigns(:streamlined_item)
  end
  
  it "hide the instance so its not an action" do 
    exception = lambda { get :instance }.should.raise(ActionController::UnknownAction)
    exception.message.should.equal "No action responded to instance"
  end

end
