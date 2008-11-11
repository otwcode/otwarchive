require File.dirname(__FILE__) + '/../test_helper'

class WorksPostControllerTest < ActionController::TestCase
  tests WorksController

  context "if you are not logged in" do
    setup do
      @work = create_work
      post :post, :locale => 'en', :id => @work.id
    end
    should_redirect_to 'new_session_url(:restricted => true)'
  end
  
  context "when logged in" do
    setup do
      @user = create_user
      @user.activate
      @request.session[:user] = @user 
    end

    context "when working with someone else's work" do
      setup do
        new_user = create_user
        chapter = new_chapter(:authors => [new_user.default_pseud])
        @work = create_work(:authors => [new_user.default_pseud], :chapters => [new_chapter])
        post :post, :locale => 'en', :id => @work.id
      end
      should_redirect_to 'work_path(@work)'
      should_set_the_flash_to /have permission/      
    end

    context "when working with your own work" do
      setup do
        @work = create_work(:authors => [@user.default_pseud])
        post :post, :locale => 'en', :id => @work.id
      end
       should_set_the_flash_to /posted/      
       should_redirect_to 'work_path(@work)'
       should "post the work" do
         assert Work.find(@work.id).posted?
       end
    end

  end
    
end
