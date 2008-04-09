require File.dirname(__FILE__) + '/../spec_helper'

describe 'A new', AuthentableEntity do

  it 'should be valid with proper attributes' do
    user = User.new
    user.attributes = valid(:user)
    user.should be_valid
  end

  it 'should be createable' do
    lambda do
      user = create_valid(:user)
      user.should_not be_new_record
    end.should change(User, :count).by(1)
  end

  it 'should require a login' do
    lambda do
      user = create_valid(:user, :login => nil)
      match_first(user.errors.on(:login), /blank/)
    end.should_not change(User, :count)
  end

  it 'should require a password' do
    lambda do
      user = create_valid(:user, :password => nil)
      match_first(user.errors.on(:password), /blank/)
    end.should_not change(User, :count)
  end

  it 'should be invalid with a very short password' do
    lambda do
      user = create_valid(:user, :password => 'abc',
                                 :password_confirmation => 'abc')
      match_first(user.errors.on(:password), /short/)
    end.should_not change(User, :count)
  end

  it 'should be invalid with a overly long password' do
    lambda do
      user = create_valid(:user, :password => 'c' * 41,
                                 :password_confirmation => 'c' * 41)
      match_first(user.errors.on(:password), /long/)
    end.should_not change(User, :count)
  end

  it 'should require a password confirmation' do
    lambda do
      user = create_valid(:user, :password_confirmation => nil)
      match_first(user.errors.on(:password_confirmation), /blank/)
    end.should_not change(User, :count)
  end

  it 'should be invalid with dissimilar password and password confirmation' do
    lambda do
      user = create_valid(:user, :password_confirmation => 'nonmatch')
      match_first(user.errors.on(:password), /doesn't match/)
    end.should_not change(User, :count)
  end

 it 'should generate and store a crypted password' do
    user = create_valid(:user)
    user.crypted_password.length.should == 60
  end
end

describe 'An existing', AuthentableEntity do
  fixtures :users

  it 'should be authenticated with a matching password' do
    users(:michael).authenticated?('apollonia').should be_true
    User.authenticate(users(:michael).login,
                            'apollonia').should == users(:michael)
  end

  it 'should be restricted with a non-matching password' do
    users(:michael).authenticated?('sollozzo').should be_false
    User.authenticate(users(:michael).login,
                            'sollozzo').should be_nil
  end

  it 'should be able to be remembered by a token' do
    users(:michael).remember_token?.should be_false

    lambda do
      users(:michael).remember_me
    end.should change(users(:michael), :remember_token)

    users(:michael).remember_token_expires_at.should
        be_close(1.month.from_now.utc, 1)
    users(:michael).remember_token?.should be_true
  end

  it 'should be able to be remembered for a given period of time' do
    before = 2.weeks.from_now.utc

    lambda do
      users(:michael).remember_me_for(2.weeks)
    end.should change(users(:michael), :remember_token)

    after = 2.weeks.from_now.utc
    users(:michael).remember_token_expires_at.should be_between(before, after)
  end

  it 'should be able to be forgotten' do
    users(:sonny).remember_token?.should be_true

    lambda do
      users(:sonny).forget_me
    end.should change(users(:sonny), :remember_token).to(nil)

    users(:sonny).remember_token_expires_at.should be_nil
    users(:sonny).remember_token?.should be_nil
  end

  it 'should be updateable without a password change' do
    users(:michael).login = 'corleone'
    users(:michael).should be_valid
    users(:michael).save.should be_true
  end

  it 'should require a password confirmation in case of password change' do
    users(:michael).password = 'NewPassword'
    users(:michael).should_not be_valid
    users(:michael).save.should be_false
  end

  it 'should store a crypted password in case of password change' do
    users(:michael).authenticated?('apollonia').should be_true
    users(:michael).update_attributes(:password => 'NewPassword',
                                      :password_confirmation => 'NewPassword')
    users(:michael).hash.should_not == hash
    users(:michael).authenticated?('NewPassword').should be_true
  end
end
