require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, 'routes should map' do

  it "{:controller=>'users', :action=>'new'} to /users/new" do
    route_for(:controller => 'users',
              :action => 'new').should == '/users/new'
  end

  it "{:controller=>'users', :action=>'create'} to /users" do
    route_for(:controller => 'users',
              :action => 'create').should == '/users'
  end
end

describe UsersController, '/users/new GET' do

  it 'should be successfull' do
    get :new
    response.should be_success
  end

  it 'should render template new' do
    get :new
    response.should render_template(:new)
  end
end

describe UsersController, '/users POST with valid params' do

  before(:each) do
    @user = mock_model(User)
    User.stub!(:new).and_return(@user)
    @user.stub!(:save!).and_return(true)
    controller.stub!(:current_user).and_return(@user)
  end

  it 'should create a new user with params' do
    User.should_receive(:new).with(
      {'email' => 'vito@corleone.it'}).and_return(@user)
    post :create, :user => {:email => 'vito@corleone.it'}
  end

  it 'should safely save the new user' do
    @user.should_receive(:save!)
    post :create
  end

  it 'should log the new user in' do
    post :create
    controller.current_user.should be(@user)
  end

  it "should redirect to root unless there exist a previous location" do
    post :create
    response.should redirect_to('http://test.host/')
  end

  it "should redirect to previous location if it exists" do
    session[:return_to] = '/some/location'
    post :create
    response.should redirect_to('http://test.host/some/location')
  end
end

describe UsersController, '/users POST with invalid params' do

  before(:each) do
    @user = mock_model(User)
    User.stub!(:new).and_return(@user)
    @user.errors.stub!(:full_messages).and_return([])
    @user.stub!(:save!).and_raise(ActiveRecord::RecordInvalid.new(@user))
  end

  it 'should not save the new user' do
    @user.should_receive(:save!).and_raise(
      ActiveRecord::RecordInvalid.new(@user))
    post :create
  end

  it "should render template new" do
    post :create
    response.should render_template(:new)
  end

  it 'should assign the user' do
    post :create
    assigns(:user).should be(@user)
  end
end

