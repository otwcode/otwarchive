require File.expand_path(File.join(File.dirname(__FILE__), '../test_functional_helper'))
include Streamlined::Column

describe "AssociationFunctional" do
  fixtures :poets, :poems

  it "associables for non polymorphic association" do
    @association = Association.new(Poet.reflect_on_association(:poems), Poet, :inset_table, :count)
    assert_equal [Poem], @association.associables
  end

  it "associables for polymorphic association" do
    @association = Association.new(Authorship.reflect_on_association(:publication), Author, :inset_table, :count)
    assert_equal_sets [Book, Article], @association.associables
  end
  
  it "render quick add for belongs to" do
    stock_controller_and_view
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count) 
    html = @association.render_quick_add(@view)
    assert_people_quick_add_link(html)                          
  end

  it "render quick add for has one" do   
    # TODO Implement support for quick_add has_one.  (You will write the test first, won't you?)
  end

  it "render quick add for has many" do   
    # TODO Implement support for quick_add has_many.  (You will write the test first, won't you?)
  end
  
  it "render td list with link to" do
    stock_controller_and_view
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count) 
    @association.link_to = { :action => "show" }
    @association.edit_in_list = false
    flexmock(@association).should_receive(:render_td_show).and_return("render")  # TODO: is there a way to avoid this mocking here?
    expected = "<div id=\"InsetTable::poet::1::Poet\"><a href=\"/people/show/1\">render</a></div>"
    assert_equal expected, @association.render_td_list(@view, poems(:haiku))
  end
  
  it "render td list with link to and edit in list" do
    stock_controller_and_view
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count) 
    @association.link_to = { :action => "show" }
    @association.edit_in_list = true
    flexmock(@association).should_receive(:render_td_show).and_return("render")  # TODO: is there a way to avoid this mocking here?
    expected = "<div id=\"InsetTable::poet::1::Poet\"><a href=\"/people/show/1\">render</a></div>" <<
               "<a href=\"#\" onclick=\"Streamlined.Relationships.open_relationship('InsetTable::poet::1::Poet', this, '/people'); return false;\">Edit</a>"
    assert_equal expected, @association.render_td_list(@view, poems(:haiku))
  end
  
  it "render td edit" do      
    stock_controller_and_view              
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count) 
    html = @association.render_td_edit(@view, poems(:limerick))
    assert_select root_node(html), "select[id=poem_poet_id]" do
      assert_select "option[value=]", "Unassigned"
      assert_select "option[value=1]", "1"
      assert_select "option[value=2][selected=selected]", "2"
    end                                       
    assert_people_quick_add_link(html)                          
  end

  it "render td edit with html options" do
    stock_controller_and_view              
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count) 
    @association.html_options = { :class => 'foo_class' }
    html = @association.render_td_edit(@view, poems(:limerick))

    assert_select root_node(html), "select[id=poem_poet_id][class=foo_class]" do
      assert_select "option[value=]", "Unassigned"
      assert_select "option[value=1]", "1"
      assert_select "option[value=2][selected=selected]", "2"
    end                                       
    assert_people_quick_add_link(html)                          
  end

  it "render td edit with unassigned value set" do      
    stock_controller_and_view              
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count) 
    @association.unassigned_value = "None"
    html = @association.render_td_edit(@view, poems(:limerick))
    assert_select root_node(html), "select[id=poem_poet_id]" do
      assert_select "option[value=]", "None"
      assert_select "option[value=1]", "1"
      assert_select "option[value=2][selected=selected]", "2"
    end                                       
    assert_people_quick_add_link(html)                          
  end
  
  it "render td edit with options for select" do
    stock_controller_and_view
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count)

    flexmock(Poet).should_receive(:custom_options_method).and_return([[:label1, :value1], [:label2, :value2]])
    @association.options_for_select = :custom_options_method

    html = @association.render_td_edit(@view, poems(:limerick))
    assert_select root_node(html), "select[id=poem_poet_id]" do
      assert_select "option[value=]", "Unassigned"
      assert_select "option[value=value1]", "label1"
      assert_select "option[value=value2]", "label2"
    end             
    assert_people_quick_add_link(html)                          
  end

  # def test_render_td_edit_for_unsupported_association_type
  #   @association = Association.new(Poet.reflect_on_association(:poems), Poet, :inset_table, :count)
  #   assert_equal '[TBD: editable associations]', @association.render_td_edit(nil, poets(:justin))
  # end
  
  def assert_people_quick_add_link(html)
    assert_select root_node(html), "a" do
      assert_select "[href=?]", %r{/people/quick_add\?.*}  
      assert_select "[href=?]", %r{.*select_id=poem_poet_id.*}
      assert_select "[href=?]", %r{.*model_class_name=Poet.*}   
      assert_select "img" do
        assert_select "[alt=Quick Add]"
        assert_select "[title=Quick Add]"
        assert_select "[class=sl_quick_add_link]"
        assert_select "[id=sl_qa_poem_poet]"
      end                                       
    end
  end
end