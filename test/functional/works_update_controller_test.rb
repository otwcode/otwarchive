require File.dirname(__FILE__) + '/../test_helper'

# FIXME needs many more tests
class WorksUpdateControllerTest < ActionController::TestCase
  tests WorksController

  context "if you are not logged in" do
    setup do
      @work = create_work
      put :update, :locale => 'en', :id => @work.id
    end
    should_redirect_to 'work_path(@work)'
    should_set_the_flash_to /have permission/      
  end
  
  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user 
    end

    context "when working with someone else's work" do
      setup do
        new_user = create_user
        @work = create_work(:authors => [new_user.default_pseud])
        put :update, :locale => 'en', :id => @work.id
      end
      should_redirect_to 'work_path(@work)'
      should_set_the_flash_to /have permission/      
    end

    context "when working with your own work" do
      setup do
        @work = create_work(:authors => [@user.default_pseud])
        put :update, :locale => 'en', :id => @work.id, :work => {:title => "new title"}
      end
      should_redirect_to 'work_path(@work)'
      should "update title" do
        assert_equal "new title", Work.find(@work.id).title
      end
    end
  end

    
end
