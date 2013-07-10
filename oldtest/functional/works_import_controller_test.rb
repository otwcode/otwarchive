require 'test_helper'

#FIXME needs many more tests
class WorksImportControllerTest < ActionController::TestCase
  tests WorksController

  context "if you are not logged in" do
    setup do
      @work = create_work
      post :import, :locale => 'en'
    end
    should_redirect_to("new session") {new_session_url}
  end

  # context "when logged in" do
  #   setup do
  #     @user = create_user
  #     @request.session[:user] = @user
  #   end
  #   context "after importing a single work" do
  #     setup {post :import, :locale => 'en', :urls => 'http://black-samvara.livejournal.com/381224.html'}
  #     should_render_template 'new'
  #   end
  #   context "after importing multiple works" do 
  #     setup do
  #       post :import, :locale => 'en', :urls => "http://black-samvara.livejournal.com/381224.html\nhttp://cupidsbow.livejournal.com/147183.html\nhttp://yuletidetreasure.org/archive/33/duende.html"        
  #     end
  #     should_render_template 'show_multiple'
  #   end    
  # end
  
end

