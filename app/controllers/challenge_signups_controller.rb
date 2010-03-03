class ChallengeSignupsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection
  before_filter :load_challenge
  before_filter :load_signup_from_id, :only => [:show, :edit, :update, :destroy]
  before_filter :allowed_to_destroy, :only => [:destroy]
  before_filter :check_signup_open, :only => [:new, :edit, :update]
  
  def check_signup_open
    signup_closed and return unless @challenge.signup_open
  end

  def signup_closed
    flash[:error] = t('challenge_signups.signup_closed', :default => "Signup is not currently open for this challenge!")
    redirect_to @collection rescue redirect_to '/'
    false
  end

  def load_challenge
    @challenge = @collection.challenge
    no_challenge and return unless @challenge
  end

  def allowed_to_destroy
    @challenge_signup.user_allowed_to_destroy?(current_user) || not_allowed
  end
  
  def load_signup_from_id
    @challenge_signup = ChallengeSignup.find(params[:id])
    no_signup and return unless @challenge_signup
  end

  def no_challenge
    flash[:error] = t('challenges.no_challenge', :default => "What challenge did you want to sign up for?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end
  
  def not_allowed
    flash[:error] = t('challenge_signups.not_allowed', :default => "Sorry, you're not allowed to do that.")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def no_signup
    flash[:error] = t('challenge_signups.no_signup', :default => "What signup did you want to work on?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end
  
  #### ACTIONS

  def index
    if @challenge.user_allowed_to_see_signups?(current_user)
      @challenge_signups = @collection.signups
    else
      @challenge_signups = @collection.signups.by_user(current_user)
    end
  end

  def show
  end

  def new
    if (@challenge_signup = ChallengeSignup.in_collection(@collection).by_user(current_user).first)
      flash[:notice] = t('challenge_signups.already_signed_up', :default => "You are already signed up for this challenge. You can edit your signup below.")
      redirect_to edit_collection_signup_path(@collection, @challenge_signup)
    else
      @challenge_signup = ChallengeSignup.new
    end
  end

  def edit
  end

  def create
    @challenge_signup = ChallengeSignup.new(params[:challenge_signup])
    @challenge_signup.collection = @collection
    if @challenge_signup.save
      flash[:notice] = 'Signup was successfully created.'
      redirect_to collection_signup_path(@collection, @challenge_signup)
    else
      render :action => :new
    end
  end

  def update
    if @challenge_signup.update_attributes(params[:challenge_signup])
      flash[:notice] = 'Signup was successfully updated.'
      redirect_to collection_signup_path(@collection, @challenge_signup)
    else
      render :action => :edit
    end
  end

  def destroy
    unless @challenge.signup_open || @collection.user_is_maintainer?(current_user)
      flash[:error] = t('challenge_signups.cannot_delete', :default => "You cannot delete your signup after signups are closed. Please contact a moderator for help.")
    else 
      @challenge_signup.destroy
      flash[:notice] = 'Challenge signup was deleted.'
    end
    redirect_to @collection rescue redirect_to '/'
  end
end
