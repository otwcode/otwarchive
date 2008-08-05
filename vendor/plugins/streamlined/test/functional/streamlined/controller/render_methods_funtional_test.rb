require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/controller/render_methods'

describe "RenderMethodsFunctional" do
  def setup
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
    class <<@controller
      public :render_tabs, :render_partials, :render_a_tab_to_string
    end
  end

  it "should render one partial" do
    assert_equal 'content1', @controller.render_partials('file1')
  end
  
  it "should render multiple partials" do
    assert_equal 'content1content2', @controller.render_partials('file1', 'file2')
  end

  it "render tabs" do
    response = @controller.render_tabs({:name => 'tab1', :partial => 'file1' }, {:name => 'tab2', :partial => 'file2'})
    #doc = REXML::Document.new(response)
    # assert_equal "tabber", doc.root.elements["/div[1]/@class"].value

    assert response =~ /tab1/
    assert response =~ /tab2/
    assert response =~ /<div class='tabber'>/
    assert response =~ /<div class='tabbertab'/
  end

  it "render tabs in order" do
    response = @controller.render_tabs({:name => 'tab1', :partial => "file1"}, 
                                       {:name => 'tab2', :partial => "file2"})
    assert response =~ /id='tab1'.*id='tab2'/
  end

  it "render tabs with missing args" do
    results = assert_raise(ArgumentError) {
      response = @controller.render_tabs({:name => 'tab1'})
    }
    assert_equal 'render args are required', results.message
    results = assert_raise(ArgumentError) {
      response = @controller.render_tabs({:partial => 'shared/foo'})
    }
    assert_equal ':name is required', results.message
  end

  it "render tabs with shared partial" do
    response = @controller.render_tabs({:name => 'tab1', :partial => 'shared/foo'})

    assert response =~ /tab1/
    assert response =~ /tabber/
    assert response =~ /tabbertab/
    assert response =~ /content3/
  end
  
  it "render partials" do
   response = @controller.render_partials('shared/foo')
   assert response =~ /^content3/
  end
  
  it "render tabs with partial and locals" do
    response = @controller.render_tabs({:name => 'tab1', :partial => 'shared/foo', :locals => {:something=>'something'}})

    assert response =~ /tab1/
    assert response =~ /tabber/
    assert response =~ /tabbertab/
    assert response =~ /content3/
    
    assert @locals = 'something'
  end
  
  it "render a tab to string" do
    expected = "<div class='tabbertab' title='My Tab' id='my_tab'>content1</div>"
    assert_equal expected, @controller.render_a_tab_to_string(:name => "My Tab", :partial => "file1")
  end
  
  it "render a tab to string with id" do
    expected = "<div class='tabbertab' title='My Tab' id='foo'>content1</div>"
    assert_equal expected, @controller.render_a_tab_to_string(:name => "My Tab", :partial => "file1", :id => "foo")
  end
  
end