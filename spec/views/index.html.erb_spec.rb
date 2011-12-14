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
        rendered.should have_selector('.intro.module')
        rendered.should have_selector('.latest.module')
      end

     it "should not display invite links" do
        render
        rendered.should_not contain "Invite a friend"
        rendered.should_not contain "Get an Invite"
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
      rendered.should contain 'Get an Invite'
    end

    it "should display create acount link when account creation enabled" do
      @admin_settings = mock(Object)
      @admin_settings.stub(:account_creation_enabled?).and_return(true)
      @admin_settings.stub(:invite_from_queue_enabled?).and_return(false)
      render
      rendered.should contain 'Log in or Create an Account'
    end
    
  end # not logged in
    
  context "when logged in as a regular user" do
      
    before(:each) do
      view.stub(:logged_in?).and_return(true)
      view.stub(:logged_in_as_admin?).and_return(false)
      user = Factory.create(:user)
      view.stub(:current_user).and_return(user)
    end

    it "should display greeting" do
      render
      rendered.should have_selector('#greeting')
    end
    
    it "should display invites link" do
      render
      rendered.should contain "Invite a friend"
    end
    
  end # logged in as regular user
end

