require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController, 'routes should map' do

  it "{:controller=>'sessions', :action=>'create'} to /session" do
    route_for(:controller => 'sessions',
              :action => 'create').should == '/session'
  end

  it "{:controller=>'sessions', :action=>'new'} to /session/new" do
    route_for(:controller => 'sessions',
              :action => 'new').should == '/session/new'
  end

  it "{:controller=>'sessions', :action=>'destroy'} to /session" do
    route_for(:controller => 'sessions',
              :action => 'destroy').should == '/session'
  end
end

describe SessionsController, '/session/new GET' do

  it 'should render new' do
    get :new
    response.should render_template(:new)
  end
end

describe SessionsController, '/session/new GET with remember cookie' do
  fixtures :users

  it 'should log in with valid token' do
    request.cookies['auth_token'] = cookie_for(:sonny)
    get :new
    controller.send(:logged_in?).should be_true
    controller.send(:authorized?).should be_true
  end

  it 'should not log in with invalid token' do
    request.cookies['auth_token'] = auth_token(:r4ndom)
    get :new
    controller.send(:logged_in?).should be_false
    controller.send(:authorized?).should be_false
  end

  it 'should not log in with expired token' do
    request.cookies['auth_token'] = cookie_for(:michael)
    get :new
    controller.send(:logged_in?).should be_false
    controller.send(:authorized?).should be_false
  end

  private

    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end

    def cookie_for(user)
      auth_token users(user).remember_token
    end
end

describe SessionsController, '/session POST' do

  before(:each) do
    @user = mock_model(User)
  end

  it 'should log valid user in and redirect' do
    User.should_receive(:authenticate).with('don',
                                            '1').and_return(@user)
    controller.should_receive(:logged_in?).and_return(true)
    post :create, :login => 'don', :password => '1'
    response.should be_redirect
  end

  it 'should not log invalid user in and render new form' do
    controller.should_receive(:logged_in?).and_return(false)
    post :create
    response.should be_success
    response.should render_template(:new)
  end

  it 'should not remember the user by default' do
    post :create
    response.cookies["auth_token"].should be_nil
  end
end

describe SessionsController, '/session POST with remember => true' do

  before(:each) do
    @user = mock_model(User)
    User.stub!(:authenticate).and_return(@user)
    @user.stub!(:logged_in?).and_return(false, true)
    @user.stub!(:remember_me)
    @user.stub!(:remember_token).and_return('s3cr3t')
    @user.stub!(:remember_token_expires_at).and_return(2.days.from_now)

    @kookies = mock('cookies')
    @kookies.stub!(:[]=)
    @kookies.stub!(:[])
    controller.stub!(:cookies).and_return(@kookies)
  end

  it 'should remember the user' do
    @user.should_receive(:remember_me)
    post :create, :login => 'don', :password => 'p', :remember_me => '1'
  end

  it 'should create remember cookie' do
    @kookies.should_receive(:[]=).with(:auth_token, { :value => 's3cr3t',
                                       :expires => @user.remember_token_expires_at })
    post :create, :login => 'don', :password => 'p', :remember_me => '1'
  end
end

describe SessionsController, '/session DELETE' do

  before(:each) do
    @user = mock_model(User)
    @user.stub!(:forget_me)

    @kookies = mock('cookies')
    @kookies.stub!(:delete)
    @kookies.stub!(:[])

    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:logged_in?).and_return(true, true)
    controller.stub!(:cookies).and_return(@kookies)
    controller.stub!(:reset_session)

    response.cookies.stub!(:delete)
  end

  it 'should forget current user' do
    @user.should_receive(:forget_me)
    delete :destroy
  end

  it "should delete token on logout" do
    @kookies.should_receive(:delete).with(:auth_token)
    delete :destroy
  end

  it 'should reset session' do 
    controller.should_receive(:reset_session)
    delete :destroy
  end

  it "should redirect to root" do
    delete :destroy
    response.should redirect_to('http://test.host/')
  end

  it "should redirect to last location" do
    session[:return_to] = 'http://test.host/something'
    delete :destroy
    response.should redirect_to('http://test.host/something')
  end
end
