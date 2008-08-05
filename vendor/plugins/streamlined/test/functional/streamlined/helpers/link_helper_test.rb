require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/helpers/link_helper'

describe "Streamlined::Helpers::LinkHelper" do
  fixtures :people, :phone_numbers
  
  def setup
    stock_controller_and_view
  end
  
  it "guess show link for" do
    assert_equal "(multiple)", @view.guess_show_link_for([])
    assert_equal "(unassigned)", @view.guess_show_link_for(nil)
    assert_equal "(unknown)", @view.guess_show_link_for(1)
    assert_equal %[<a href="/people/show/1">1</a>], @view.guess_show_link_for(people(:justin))
    assert_equal %[<a href="/phone_numbers/show/1">1</a>], @view.guess_show_link_for(phone_numbers(:number1))
  end
  
  it "guess show link for model with to param override" do
    model = people(:justin)
    flexmock(model).stubs(:to_param).returns("some_seo_slug")
    assert_equal %[<a href="/people/show/1">1</a>], @view.guess_show_link_for(model)
  end
  
  # TODO: make link JavaScript unobtrusive!
  it "link to new model" do
    result = @view.link_to_new_model
    assert_select root_node(result), "a[href=/people/new]" do
      assert_select "img[alt=New Person][border=0][src=/images/streamlined/add_16.png][title=New Person]"
    end
  end
  
  it "link to new model when quick new button is false" do
    @view.send(:model_ui).quick_new_button false
    assert_nil @view.link_to_new_model
  end

  it "link to edit model" do
    result = @view.link_to_edit_model(people(:justin))
    assert_select root_node(result), "a[href=/people/edit/1]" do
      assert_select "img[alt=Edit Person][border=0][src=/images/streamlined/edit_16.png][title=Edit Person]"
    end
  end
  
  it "link to edit model with to param override" do
    model = people(:justin)
    flexmock(model).stubs(:to_param).returns("some_seo_param")
    
    result = @view.link_to_edit_model(model)
    assert_select root_node(result), "a[href=/people/edit/1]" do
      assert_select "img[alt=Edit Person][border=0][src=/images/streamlined/edit_16.png][title=Edit Person]"
    end
  end
  
  it "link to show model" do
    model = flexmock(:id => 1)
    assert_equal %[<a href="/people/show/1"><img alt="Show Person" border="0" src="/images/streamlined/search_16.png" title="Show Person" /></a>], @view.link_to_show_model(model)
  end
  
  it "link to show model with to param override" do
    model = flexmock(:id => 1, :to_param => "some_seo_param")
    assert_equal %[<a href="/people/show/1"><img alt="Show Person" border="0" src="/images/streamlined/search_16.png" title="Show Person" /></a>], @view.link_to_show_model(model)
  end
  
  it "link to delete model" do
    model = people(:justin)
    assert_equal "<a href=\"/people/destroy/1\" onclick=\"if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none';" <<
                 " this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden');" <<
                 " m.setAttribute('name', '_method'); m.setAttribute('value', 'post'); f.appendChild(m);f.submit(); };return false;\"><img alt=\"Destroy\" " << 
                 "border=\"0\" src=\"/images/streamlined/delete_16.png\" title=\"Destroy\" /></a>", @view.link_to_delete_model(model)
  end
  
  it "link to delete model with to param" do
    model = people(:justin)
    flexmock(model).stubs(:to_param).returns("some_seo_param")
    assert_equal "<a href=\"/people/destroy/1\" onclick=\"if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none';" <<
                 " this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden');" <<
                 " m.setAttribute('name', '_method'); m.setAttribute('value', 'post'); f.appendChild(m);f.submit(); };return false;\"><img alt=\"Destroy\" " << 
                 "border=\"0\" src=\"/images/streamlined/delete_16.png\" title=\"Destroy\" /></a>", @view.link_to_delete_model(model)
  end

  it "wrap with link" do
    result = @view.wrap_with_link("show") {"foo"}
    assert_select root_node(result), "a[href=show]", "foo"
  end
  
  it "wrap with link with empty block" do
    result = @view.wrap_with_link("show") {}
    assert_select root_node(result), "a[href=show]", "show"
  end
  
  it "wrap with link with array" do
    result = @view.wrap_with_link(["foo", {:action => "show", :id => "1"}]) {"bar"}
    assert_select root_node(result), "a[href=foo][action=show][id=1]", "bar"
  end
  
  it "wrap with link with array and empty block" do
    result = @view.wrap_with_link(["foo", {:action => "show", :id => "1"}]) {}
    assert_select root_node(result), "a[href=foo][action=show][id=1]", "foo"
  end
  
  it "link toggle element" do
    assert_equal '<a href="#some_elem" class="sl_toggler">click me</a>',
                 @view.link_to_toggler('click me', 'some_elem')
  end

  it "link to toggle export" do
    html = @view.send("link_to_toggle_export")
    title = "Export People"
    look_for   = "a[href=#][onclick=\"Element.toggle('show_export'); return false;\"]"
    look_for_2 = "img[alt=#{title}][border=0][src=/images/streamlined/export_16.png][title=#{title}]"
    count = 1
    error_msg   = "Did not find #{look_for  } with count=#{count} in #{html}"
    error_msg_2 = "Did not find #{look_for_2} with count=#{count} in #{html}"
    assert_select root_node(html), look_for, {:count => count}, error_msg do
      assert_select look_for_2, {:count => count}, error_msg_2
    end  
  end

  it "link to toggle export with none" do
    @view.send(:model_ui).exporters :none                                                                                                                          
    assert_equal :none, @view.send(:model_ui).exporters
    html = @view.send("link_to_toggle_export")
    assert html.blank?, "html=#{html}.  It should be empty"
  end

  it "link to submit export" do
    html = @view.send("link_to_submit_export", {:action => :list})
    look_for = "a[href=#][onclick=\"Streamlined.Exporter.submit_export('/people/list'); return false;\"]"
    text = "Export"
    count = 1
    error_msg = "Did not find #{look_for} with count=#{count} and text=#{text} in #{html}"
    assert_select root_node(html), look_for, {:count => count, :text => text}, error_msg
  end

  it "link to hide export" do
    html = @view.send("link_to_hide_export")
    look_for = "a[href=#][onclick=\"Element.hide('show_export'); return false;\"]"
    text = "Cancel"
    count = 1
    error_msg = "Did not find #{look_for} with count=#{count} and text=#{text} in #{html}"
    assert_select root_node(html), look_for, {:count => count, :text => text}, error_msg
  end

  it "show columns to export is true for default" do
    formats = :csv, :json, :xml, :enhanced_xml_file, :xml_stylesheet, :enhanced_xml, :yaml
    @view.send(:model_ui).exporters formats
    assert_equal formats, @view.send(:model_ui).exporters
    assert_true @view.send("show_columns_to_export")
  end

  it "show columns to export is true" do
    formats = :enhanced_xml, :enhanced_xml_file, :xml_stylesheet
    formats.each do |format|
      @view.send(:model_ui).exporters format
      assert_equal format, @view.send(:model_ui).exporters
      assert_true @view.send("show_columns_to_export")
    end
  end

  it "show columns to export is false" do
    formats = :csv, :json, :xml, :yaml
    formats.each do |format|
      @view.send(:model_ui).exporters format
      assert_equal format, @view.send(:model_ui).exporters
      assert_false @view.send("show_columns_to_export")
    end
  end
end
