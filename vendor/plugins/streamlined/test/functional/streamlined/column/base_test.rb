require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/helpers/link_helper'

describe "Streamlined::Column::Base" do
  fixtures :people
  
  # s/b setup but for some reason rcov doesn't call setup (this class only)
  def ui
    unless @ui
      stock_controller_and_view
      @ui = Streamlined::UI.new(Person)
    end
    @ui
  end
                   
  def teardown
    Streamlined::PermanentRegistry.reset
  end

  it "column value" do
    ui
    @view.instance_variable_set(:@person, people(:justin))
    column = ui.column(:first_name)
    assert_nil column.custom_column_value(@view, "person", "first_name"), 
               "custom_column value should be nil unless format_for_edit returns something different than the column value after type cast"
    Streamlined.edit_format_for("Justin") {"Off your coastline, mutatin' your villagerz"}
    assert_equal "Off your coastline, mutatin' your villagerz", column.custom_column_value(@view, "person", "first_name")
  end
  
  it "render td edit with custom edit format for" do
    ui
    @view.instance_variable_set(:@person, people(:justin))
    column = ui.column(:first_name)
    root = root_node(column.render_td_edit(@view, people(:justin)))
    assert_select root, "input[id=person_first_name][value=Justin][type=text]"    
    Streamlined.edit_format_for("Justin") {"Da Man, nay, The Machine"}
    root = root_node(column.render_td_edit(@view, people(:justin)))
    assert_select root, "input[id=person_first_name][value=Da Man, nay, The Machine][type=text]"
  end
  
  it "render straight td" do
    assert_equal "Justin", ui.column(:first_name).render_td(@view,people(:justin))
  end

  it "render link td" do
    ui.user_columns :first_name, {:link_to=>{:action=>"foo"}}
    assert_equal '<a href="/people/foo/1">Justin</a>', ui.column(:first_name).render_td(@view,people(:justin))
    assert_equal '<a href="/people/foo/2">Stu</a>', ui.column(:first_name).render_td(@view,people(:stu))
  end

  it "render popup td" do
    ui.user_columns :first_name, {:popup=>{:action=>"foo"}}
    assert_equal '<span class="sl-popup"><a href="/people/foo/1" style="display:none;"></a>Justin</span>', ui.column(:first_name).render_td(@view,people(:justin))
  end
  
  it "sort image up" do
    options = Streamlined::Context::RequestContext.new(:sort_column=>"first_name")
    assert_equal "<img alt=\"Arrow-up_16\" border=\"0\" height=\"10px\" src=\"/images/streamlined/arrow-up_16.png\" />", 
                 ui.column(:first_name).sort_image(options,@view)
  end

  it "sort image down" do
    options = Streamlined::Context::RequestContext.new(:sort_column=>"first_name", :sort_order=>"DESC")
    assert_equal "<img alt=\"Arrow-down_16\" border=\"0\" height=\"10px\" src=\"/images/streamlined/arrow-down_16.png\" />", 
                 ui.column(:first_name).sort_image(options,@view)
  end

  it "sort image none" do
    options = Streamlined::Context::RequestContext.new
    assert_equal '', ui.column(:first_name).sort_image(options,nil)
  end
  
  it "div wrapper" do
    result = ui.column(:first_name).div_wrapper(123) { 'contents' }
    assert_equal "<div id=\"123\">contents</div>", result
  end
  
  it "render tr edit" do
    # simulate controller, view, context, and ivar naming convention...
    ui
    @controller.send :crud_context=, :edit
    @view.instance_variable_set(:@person, people(:stu))
    # and then test what we get
    root = root_node(ui.column(:first_name).render_tr_edit(@view, people(:stu)))
    assert_select root, "tr[id=sl_field_person_first_name]" do
      assert_select "td[class=sl_edit_label]" do
        assert_select "label[for=person_first_name]", "First Name"
      end
      assert_select "td[class=sl_edit_value]" do
        assert_select "input[id=person_first_name][size=30][value=Stu][type=text]" do
          assert_select "[name=?]", "person[first_name]"
        end
      end
    end
  end
end