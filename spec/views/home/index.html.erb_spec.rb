require 'spec_helper'
 	
describe "home/index.html.erb" do
  it "should display the welcome box" do
    view.stub(:logged_in?).and_return(false)
    view.stub(:logged_in_as_admin?).and_return(false)
    render
    rendered.should contain 'Welcome'
    rendered.should contain 'News'
    rendered.should contain 'Archive'
    rendered.should contain 'fandoms'
  end

end
