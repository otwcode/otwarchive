require 'spec_helper'
 	
describe "home/index.html.erb" do

  it "should display the typical boxes and key words" do
    view.stub(:logged_in?).and_return(false)
    view.stub(:logged_in_as_admin?).and_return(false)
    render
    rendered.should contain 'Welcome'
    rendered.should_not contain 'News'
    rendered.should contain 'Archive'
    rendered.should have_selector('ul', :class => 'navigation', :content => 'fandoms')
  end
  
  context "when logged in as a regular user" do

      before do
        view.stub(:logged_in?).and_return(true)
        view.stub(:logged_in_as_admin?).and_return(false)
        current_user = Factory.create(:user)
        render
      end
      
      it "should display invites link" do
        rendered.should contain "Invite a friend"
      end
      
  end
  
  context "when admin posts exist" do

      before do
        @adminpost = Factory.create(:admin_post)
        view.stub(:logged_in?).and_return(false)
        view.stub(:logged_in_as_admin?).and_return(false)
        render
      end
      
      it "should display news posts" do
        rendered.should contain "News"
      end
      
  end

end
