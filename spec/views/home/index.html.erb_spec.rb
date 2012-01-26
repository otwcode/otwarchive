require 'spec_helper'
 	
describe "home/index.html.erb" do

  context "when not logged in" do
  
    before(:each) do
      view.stub(:logged_in?).and_return(false)
      view.stub(:logged_in_as_admin?).and_return(false)
      view.stub(:current_user).and_return(nil)
    end
    
    context "when account creation and invites are disabled" do
      before(:each) do
        @admin_settings = mock(Object)
        @admin_settings.stub(:account_creation_enabled?).and_return(false)
        @admin_settings.stub(:invite_from_queue_enabled?).and_return(false)
      end
      
      it "should display the typical boxes" do
        render
        rendered.should have_selector('.primary.navigation')
        rendered.should have_selector('.intro.module') # Welcome
        rendered.should have_selector('.latest.module')
      end

     it "should not display invite links" do
				render
				# See http://stackoverflow.com/questions/4706370/rspec-view-testing-with-capybara-and-rails3/4773050#4773050# for why
				page = Capybara::Node::Simple.new( rendered )
        page.should_not have_content "Invite a friend"
        page.should_not have_content "Get an Invite"
      end

      it "should not display news when there are no admin posts" do
        render
        rendered.should_not have_selector('.news.module')
      end

      it "should display news when there are admin posts" do
        @admin_post = Factory.create(:admin_post)
        render
        rendered.should have_selector('.news.module', :content => @admin_post.title)
      end

      it "should not display greeting" do
        render
        rendered.should_not have_selector('#greeting')
      end

    end # account creation and invites are disabled

    it "should display get invite link when invite queue enabled" do
      @admin_settings = mock(Object)
      @admin_settings.stub(:account_creation_enabled?).and_return(false)
      @admin_settings.stub(:invite_from_queue_enabled?).and_return(true)
			render
			# See http://stackoverflow.com/questions/4706370/rspec-view-testing-with-capybara-and-rails3/4773050#4773050# for why
			page = Capybara::Node::Simple.new( rendered )
      page.should have_content 'Get an Invite'
    end

    it "should display create acount link when account creation enabled" do
      @admin_settings = mock(Object)
      @admin_settings.stub(:account_creation_enabled?).and_return(true)
      @admin_settings.stub(:invite_from_queue_enabled?).and_return(false)
			render
			# See http://stackoverflow.com/questions/4706370/rspec-view-testing-with-capybara-and-rails3/4773050#4773050# for why
			page = Capybara::Node::Simple.new( rendered )
      page.should have_content 'Log in or Create an Account'
    end
    
  end # not logged in
  
  context "when logged in as a regular user" do

    before do
      view.stub(:logged_in?).and_return(true)
      view.stub(:logged_in_as_admin?).and_return(false)
      user = Factory.create(:user)
      view.stub(:current_user).and_return(user)
      render
    end
      
    it "should display greeting" do
      rendered.should have_selector('#greeting')
    end
      
    it "should display invites link" do
      render
			# See http://stackoverflow.com/questions/4706370/rspec-view-testing-with-capybara-and-rails3/4773050#4773050# for why
			page = Capybara::Node::Simple.new( rendered )
			page.should have_content "Invite a friend"
    end
      
  end # logged in as regular user

end
