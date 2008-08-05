require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/helpers/filter_helper'

describe "Streamlined::Helpers::FilterHelperFunctional" do
  fixtures :people, :poems
  
  def setup
    stock_controller_and_view
    Streamlined::ReloadableRegistry.reset
    @person_ui = Streamlined.ui_for(Person) do
      user_columns :first_name, 
                   :last_name, 
                   :full_name
    end    
  end

  # Check that last_name first_name get included for filtering
  # and that the UI column "full_name" is excluded
  it "simple advanced filter columns" do
    advanced_filter_columns = @view.advanced_filter_columns
    assert_equal 3, @person_ui.user_columns.length, "Should only have 3 person columns in total"
    assert_equal 2, advanced_filter_columns.length, "Should only have 2 person columns to filter on"
    assert_equal [["First Name", "first_name"],["Last Name", "last_name"]], advanced_filter_columns
  end

  # Check that relation columns Articles::title and Books::title as well as
  # first_name and last_name get included for filtering
  # and that the UI column "full_name" and relation authorships are excluded
  it "complex advanced filter columns" do
    complex_controller_and_view
    advanced_filter_columns = @view.advanced_filter_columns
    assert_equal 6, @author_ui.user_columns.length
    assert_equal 4, advanced_filter_columns.length
    assert_equal [["Articles (Title)", "rel::articles::title"],
                  ["Books (Title)", "rel::books::title"],
                  ["First Name", "first_name"],
                  ["Last Name", "last_name"]], advanced_filter_columns
  end
  
  def complex_controller_and_view
#    setup_routes
    ActionController::Routing.use_controllers! %w(people poems)
    @controller = AuthorsController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @item = Struct.new(:id).new(1)
    get 'index'
    @view = @response.template

    Streamlined::ReloadableRegistry.reset
    @author_ui = Streamlined.ui_for(Author) do
      user_columns :first_name, 
                   :last_name, 
                   :full_name,
                   :authorships,
                   :articles,
                   :books
    end    
  end

  def advanced_controller_and_view
    @controller = ArticlesController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @item = Struct.new(:id).new(1)
    get 'index'
    @view = @response.template
  end
  
  def advanced_filter_checking
    advanced_filter_columns = @view.advanced_filter_columns
    assert_equal 3, @article_ui.column(:authors, :crud_context => :list).show_view.fields.length, "Testing that there are 3 fields of which 2 will be picked."
    assert_equal [:first_name, :last_name, :full_name], @article_ui.column(:authors, :crud_context => :list).show_view.fields, "Testing that there are 3 fields of which 2 will be picked."
    assert_equal 3, advanced_filter_columns.length, "Should have 3 columns to filter on Author-last_name, Author-first_name and Title"
    assert_equal [["Authors (First name)", "rel::authors::first_name"],["Authors (Last name)", "rel::authors::last_name"],["Title", "title"]], advanced_filter_columns, "Should have 3 columns to filter on Author-last_name, Author-first_name and Title"
  end

  # Check that relation columns Authors::last_name and Authors::first_name get included for filtering
  # and that Authors::full_name does not since it is not a db field, just a define in Author.rb 
  # using user_columns
  it "advanced filter columns with fields and user columns" do
    advanced_controller_and_view
    
    Streamlined::ReloadableRegistry.reset
    @article_ui = Streamlined.ui_for(Article) do
      user_columns :title, 
                   :authors, 
                   {
                     :show_view => [:name, {:fields => [:first_name, :last_name, :full_name]}],
                     :edit_view => [:select, {:fields => [:first_name, :last_name, :full_name]}]
                   }
    end    
    assert_equal 2, @article_ui.user_columns.length, "Should only have 2 user_columns"

    advanced_filter_checking
  end

  # Check that relation columns Authors::last_name and Authors::first_name get included for filtering
  # and that Authors::full_name does not since it is not a db field, just a define in Author.rb 
  # using list_columns
  it "advanced filter columns with fields and list columns" do
    advanced_controller_and_view

    Streamlined::ReloadableRegistry.reset
    @article_ui = Streamlined.ui_for(Article) do
      list_columns :title, 
                   :authors, 
                   {
                     :show_view => [:name, {:fields => [:first_name, :last_name, :full_name]}],
                     :edit_view => [:select, {:fields => [:first_name, :last_name, :full_name]}]
                   }
    end    
    assert_equal 2, @article_ui.list_columns.length, "Should only have 2 list_columns"

    advanced_filter_checking
  end

  
end