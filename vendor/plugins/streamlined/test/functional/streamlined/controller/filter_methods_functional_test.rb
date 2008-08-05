require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/controller/filter_methods'

include Streamlined::Controller::FilterMethods

describe "FilterMethodsFunctional" do

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
#    class <<@controller
#      public :render_tabs, :render_partials, :render_a_tab_to_string
#    end
  end

  it "add a filter" do
    filter_column = "first_name"
    filter_value = "jus"
    operand = "like"
    sql_value = "%jus%"
    conditions_string = "people.#{filter_column} like ?,%#{filter_value}%"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  def add_two_filters
    filter_column = "first_name"
    filter_value = "jus"
    operand = "like"
    sql_value = "%jus%"
    conditions_string = "people.#{filter_column} like ?,%#{filter_value}%"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)

    filter_column = "last_name"
    filter_value = "geh"
    operand = "like"
    sql_value = "%geh%"
    conditions_string = "people.first_name like ? AND people.last_name like ?,%jus%,%geh%"
    num_filters = 2
    filter_index = 2

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end
  
  it "can add two filters" do
    add_two_filters
  end
  
  it "add a filter with an equals sign operand" do
    filter_column = "first_name"
    filter_value = "=jus"
    operand = "="
    sql_value = "jus"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with a less than sign operand" do
    filter_column = "first_name"
    filter_value = "<j"
    operand = "<"
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with spaces after the operand" do
    filter_column = "first_name"
    filter_value = "<       j"
    operand = "<"
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end


  it "add a filter with a less than or equals sign operand" do
    filter_column = "first_name"
    filter_value = "<=j"
    operand = "<="
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with a greater than sign operand" do
    filter_column = "first_name"
    filter_value = ">j"
    operand = ">"
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with a greater than or equals sign operand" do
    filter_column = "first_name"
    filter_value = ">=j"
    operand = ">="
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with the after operand" do
    filter_column = "first_name"
    filter_value = "after j"
    operand = ">"
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with mixed case operand" do
    filter_column = "first_name"
    filter_value = "AftEr j"
    operand = ">"
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with upper case operand" do
    filter_column = "first_name"
    filter_value = "AFTER J"
    operand = ">"
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with the before operand" do
    filter_column = "first_name"
    filter_value = "before j"
    operand = "<"
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with the word after not an operand" do
    filter_column = "first_name"
    filter_value = "afterj"
    operand = "like"
    sql_value = "%afterj%"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with the word before not an operand" do
    filter_column = "first_name"
    filter_value = "beforej"
    operand = "like"
    sql_value = "%beforej%"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end
  
  it "add a filter with the word is not an operand" do
    filter_column = "first_name"
    filter_value = "isj"
    operand = "like"
    sql_value = "%isj%"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with the is operand" do
    filter_column = "first_name"
    filter_value = "is j"
    operand = "="
    sql_value = "j"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with is null" do
    filter_column = "first_name"
    filter_value = "is null"
    operand = "is"
    sql_value = "nil"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with is null with spaces" do
    filter_column = "first_name"
    filter_value = "is  null  "
    operand = "is"
    sql_value = "nil"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with is nil" do
    filter_column = "first_name"
    filter_value = "is nil"
    operand = "is"
    sql_value = "nil"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with is blank" do
    filter_column = "first_name"
    filter_value = "is blank"
    operand = "is"
    sql_value = "nil"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with is empty" do
    filter_column = "first_name"
    filter_value = "is empty"
    operand = "is"
    sql_value = "nil"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  it "add a filter with is space" do
    filter_column = "first_name"
    filter_value = "is "
    operand = "is"
    sql_value = "nil"
    conditions_string = "people.#{filter_column} #{operand} ?,#{sql_value}"
    num_filters = 1
    filter_index = 1

    add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
  end

  def add_a_filter(filter_column, filter_value, operand, sql_value, conditions_string, num_filters, filter_index)
    xhr(:post,  :add_filter, {:filter_column => filter_column, :filter_value => filter_value })

    assert_response :success
    msg_part = "Did not assign param correctly for: "
    assert_equal filter_column,     assigns(:column),     msg_part + "column"
    assert_equal filter_value,      assigns(:value),      msg_part + "value"
    assert_equal conditions_string, assigns(:conditions), "Wrong condtions generated"
    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/add_filter.rjs', "Wrong template rendered"

    assert_equal num_filters, session[:num_filters],  "num_filters should be #{num_filters}"
    assert_equal filter_index, session[:filter_index], "filter_index should be #{filter_index}"
    msg_part = " stored in session"
    assert_equal filter_column,             session["filter_column__#{filter_index}"],  "Incorrect column"  + msg_part
    assert_equal sql_value,                 session["filter_value__#{filter_index}"],   "Incorrect value"   + msg_part
    assert_equal operand,                   session["filter_operand__#{filter_index}"], "Incorrect operand" + msg_part
    
    # if we are adding the first filter check that @expired is set so that add_filter.rjs adds to the page correctly.
    if filter_index == 1
      assert_true assigns(:expired)
      assert_rjs :replace_html, "advanced_filter"
    else
      assert_false assigns(:expired)
      assert_rjs :insert_html, :bottom, "advanced_filter"
    end

    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    
    check_for = "Form\.reset(\"add_filter_form\")"
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")

    assert_rjs :hide, "filter_session_expired_msg"

  end

  it "should delete a filter" do
    delete_a_filter
  end
  
  def delete_a_filter
    add_two_filters

    filter_num = 1

    xhr(:post,  :delete_filter, {:id => filter_num})

    num_filters = 1
    filter_index = 2
    conditions_string = "people.last_name like ?,%geh%"
    
    assert_response :success
    msg_part = "Did not assign param correctly for: "
    assert_equal filter_num.to_s,   assigns(:filter_num), msg_part + "filter_num"
    assert_equal conditions_string, assigns(:conditions), "Wrong condtions generated"
    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/delete_filter.rjs', "Wrong template rendered"

    assert_equal num_filters, session[:num_filters],  "num_filters should be #{num_filters}"
    assert_equal filter_index, session[:filter_index], "filter_index should be #{filter_index}"

    msg_part = " should be nil"
    assert_nil session["filter_column__1"], "session[\"filter_column__1\"]" + msg_part
    assert_nil session["filter_value__1"], "session[\"filter_value__1\"]" + msg_part
    assert_nil session["filter_operand__1"], "session[\"filter_operand__1\"]" + msg_part

    msg_part = " stored in session"
    assert_equal "last_name",             session["filter_column__#{filter_index}"],  "Incorrect column"  + msg_part
    assert_equal "%geh%",                 session["filter_value__#{filter_index}"],   "Incorrect value"   + msg_part
    assert_equal "like",                  session["filter_operand__#{filter_index}"], "Incorrect operand" + msg_part

    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    assert_rjs :remove, "filter_#{filter_num}"
    assert_rjs :hide, "filter_session_expired_msg"
  end

  it "delete each filter" do
    delete_a_filter
    
    filter_num = 2

    xhr(:post,  :delete_filter, {:id => filter_num})

    num_filters = 0
    filter_index = 2
    conditions_string = ""
    
    assert_response :success
    msg_part = "Did not assign param correctly for: "
    assert_equal filter_num.to_s,   assigns(:filter_num), msg_part + "filter_num"
    assert_equal conditions_string, assigns(:conditions), "Wrong condtions generated"
    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/delete_filter.rjs', "Wrong template rendered"

    assert_equal num_filters, session[:num_filters],  "num_filters should be #{num_filters}"
    assert_equal filter_index, session[:filter_index], "filter_index should be #{filter_index}"

    for filter_index in 1..2
      assert_nil session["filter_column__#{filter_index}"]
      assert_nil session["filter_value__#{filter_index}"]
      assert_nil session["filter_operand__#{filter_index}"]
    end

    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    assert_rjs :remove, "filter_#{filter_num}"
    assert_rjs :hide, "filter_session_expired_msg"

  end

  it "update 2 filters" do
    add_two_filters

    filter_num = 1
    filter_column = "last_name"
    filter_value = "geht"

    xhr(:post,  :update_filter, {:id => filter_num, "filter_column__#{filter_num}".to_sym => filter_column, "filter_value__#{filter_num}".to_sym => filter_value})

    num_filters = 2
    filter_index = 2
    conditions_string = "people.last_name like ? AND people.last_name like ?,%geht%,%geh%"
    
    assert_response :success
    msg_part = "Did not assign param correctly for: "

    assert_equal filter_num.to_s,   assigns(:filter_num), msg_part + "filter_num"
    assert_equal filter_column,     assigns(:column),     msg_part + "column"
    assert_equal filter_value,      assigns(:value),      msg_part + "value"
    assert_equal conditions_string, assigns(:conditions), "Wrong condtions generated"

    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/update_filter.rjs', "Wrong template rendered"

    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    assert_rjs :hide, "filter_session_expired_msg"

    assert_equal num_filters,   session[:num_filters],  "num_filters should be #{num_filters}"
    assert_equal filter_index,  session[:filter_index], "filter_index should be #{filter_index}"

    msg_part = " stored in session"

    filter_index = 1
    assert_equal "last_name", session["filter_column__#{filter_index}"],  "Incorrect column"  + msg_part
    assert_equal "%geht%",    session["filter_value__#{filter_index}"],   "Incorrect value"   + msg_part
    assert_equal "like",      session["filter_operand__#{filter_index}"], "Incorrect operand" + msg_part

    filter_index = 2
    assert_equal "last_name", session["filter_column__#{filter_index}"],  "Incorrect column"  + msg_part
    assert_equal "%geh%",     session["filter_value__#{filter_index}"],   "Incorrect value"   + msg_part
    assert_equal "like",      session["filter_operand__#{filter_index}"], "Incorrect operand" + msg_part

    # now update the second one
    filter_num = 2
    filter_column = "first_name"
    filter_value = "jus"

    xhr(:post,  :update_filter, {:id => filter_num, "filter_column__#{filter_num}".to_sym => filter_column, "filter_value__#{filter_num}".to_sym => filter_value})

    num_filters = 2
    filter_index = 2
    conditions_string = "people.last_name like ? AND people.first_name like ?,%geht%,%jus%"
    
    assert_response :success
    msg_part = "Did not assign param correctly for: "

    assert_equal filter_num.to_s,   assigns(:filter_num), msg_part + "filter_num"
    assert_equal filter_column,     assigns(:column),     msg_part + "column"
    assert_equal filter_value,      assigns(:value),      msg_part + "value"
    assert_equal conditions_string, assigns(:conditions), "Wrong condtions generated"

    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/update_filter.rjs', "Wrong template rendered"

    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    assert_rjs :hide, "filter_session_expired_msg"

    assert_equal num_filters,   session[:num_filters],  "num_filters should be #{num_filters}"
    assert_equal filter_index,  session[:filter_index], "filter_index should be #{filter_index}"

    msg_part = " stored in session"

    filter_index = 1
    assert_equal "last_name",   session["filter_column__#{filter_index}"],  "Incorrect column"  + msg_part
    assert_equal "%geht%",      session["filter_value__#{filter_index}"],   "Incorrect value"   + msg_part
    assert_equal "like",        session["filter_operand__#{filter_index}"], "Incorrect operand" + msg_part

    filter_index = 2
    assert_equal "first_name",  session["filter_column__#{filter_index}"],  "Incorrect column"  + msg_part
    assert_equal "%jus%",       session["filter_value__#{filter_index}"],   "Incorrect value"   + msg_part
    assert_equal "like",        session["filter_operand__#{filter_index}"], "Incorrect operand" + msg_part

  end

  it "clear all filters" do
    add_two_filters
    
    xhr(:post,  :clear_all_filters, {})

    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/clear_all_filters.rjs', "Wrong template rendered"
    
    assert_nil session[:num_filters]
    assert_nil session[:filter_index]
    
    for filter_index in 1..2
      assert_nil session["filter_column__#{filter_index}"]
      assert_nil session["filter_value__#{filter_index}"]
      assert_nil session["filter_operand__#{filter_index}"]
    end

    conditions_string = ""
    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    assert_rjs :replace_html, "advanced_filter", ""
    assert_rjs :hide, "filter_session_expired_msg"
    
  end  

  # simulate expired session by not adding the filters.
  it "update a filter when filter session expired" do
    filter_num = 1
    filter_column = "last_name"
    filter_value = "geht"

    xhr(:post,  :update_filter, {:id => filter_num, "filter_column__#{filter_num}".to_sym => filter_column, "filter_value__#{filter_num}".to_sym => filter_value})

    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/filter_session_expired.rjs', "Wrong template rendered"

    conditions_string = ""
    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    assert_rjs :replace_html, "advanced_filter", ""
    assert_rjs :show, "filter_session_expired_msg"

  end

  it "delete a filter when filter session expired" do
    filter_num = 1

    xhr(:post,  :delete_filter, {:id => filter_num})

    assert_response :success
    assert_template STREAMLINED_TEMPLATE_ROOT + '/shared/filter_session_expired.rjs', "Wrong template rendered"

    conditions_string = ""
    check_for = "\$(\'page_options_advanced_filter\')\.value =  \"#{conditions_string}\" "
    assert_response_contains(check_for, "Did not find exact match for #{check_for} in #{@response.body}")
    assert_rjs :replace_html, "advanced_filter", ""
    assert_rjs :show, "filter_session_expired_msg"
  end  
  
end