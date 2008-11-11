require File.dirname(__FILE__) + '/../test_helper'

#FIXME needs many more tests
class WorksUploadWorkControllerTest < ActionController::TestCase
  tests WorksController

  context "if you are not logged in" do
    setup do
      @work = create_work
      post :upload_work, :locale => 'en'
    end
    should_redirect_to 'new_session_url(:restricted=>true)'
  end
  
  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user 
      post :upload_work, :locale => 'en', :work_url => 'http://black-samvara.livejournal.com/381224.html'
    end
    should_render_template 'new'
  end
    
end
