class ExternalAuthorsController < ApplicationController
  before_filter :load_user
  before_filter :check_ownership, :only => [:create, :edit, :destroy, :new]
  before_filter :check_user_status, :only => [:new, :create, :edit]
  before_filter :get_external_author_from_invitation, :only => [:claim, :complete_claim]
  before_filter :users_only, :only => [:complete_claim]

  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end

  def index
    if @user && current_user == @user
      @external_authors = @user.external_authors
    elsif logged_in? && current_user.archivist
      @external_authors = ExternalCreatorship.find_all_by_archivist_id(current_user).collect(&:external_author).uniq
    elsif logged_in?
      redirect_to user_external_authors_path(current_user) and return
    else
      flash[:notice] = "You can't see that information."
      redirect_to root_path and return
    end
  end

  def new
    flash[:notice] = "Coming soon!"
    redirect_to :action => :index
    # @external_author = ExternalAuthor.new
    # @external_author.external_author_names.build
  end

  def create
    # we need to confirm email addresses before we hand them over
    flash[:notice] = "Coming soon!"
    redirect_to :action => :index
    
    # @external_author = ExternalAuthor.new(params[:external_author])
    # if @user == current_user
    #   @external_author.is_claimed = true
    #   @external_author.user = @user
    # end
    # 
    # if @external_author.save
    #   flash[:notice] = 'ExternalAuthor was successfully created.'
    #   redirect_to user_external_authors_path(@user)
    # else
    #   render :action => "new"
    # end
  end

  def destroy
    flash[:notice] = "Coming soon!"
    redirect_to :action => :index
    # @external_author = ExternalAuthor.find(params[:id])
    # @external_author.destroy
    # 
    # redirect_to user_external_authors_path(@user)
  end

  def edit
    @external_author = ExternalAuthor.find(params[:id])
  end
  
  def get_external_author_from_invitation
    token = params[:invitation_token] || (params[:user] && params[:user][:invitation_token])
    @invitation = Invitation.find_by_token(token)
    unless @invitation
      flash[:error] = ts("You need an invitation to do that.")
      redirect_to root_path and return
    end
      
    @external_author = @invitation.external_author
    unless @external_author
      flash[:error] = ts("There are no stories to claim on this invitation. Did you want to sign up instead?")
      redirect_to signup_path(@invitation.token) and return
    end
  end

  def claim
  end

  def complete_claim
    # go ahead and give the user the works
    @external_author.claim!(current_user)
    @invitation.mark_as_redeemed(current_user) if @invitation
    flash[:notice] = t('external_author_claimed', :default => "We have added the stories imported under %{email} to your account.", :email => @external_author.email)
    redirect_to user_external_authors_path(current_user)
  end

  def update
    @invitation = Invitation.find_by_token(params[:invitation_token])
    @external_author = ExternalAuthor.find(params[:id])
    unless (@invitation && @invitation.external_author == @external_author) || @external_author.user == current_user
      flash[:error] = "You don't have permission to do that."
      redirect_to root_path and return
    end
    
    flash[:notice] = ""
    if params[:imported_stories] == "nothing"
      flash[:notice] += "Okay, we'll leave things the way they are! You can use the email link any time if you change your mind."
      redirect_to root_path and return      
    elsif params[:imported_stories] == "orphan"
      # orphan the works
      @external_author.orphan(params[:remove_pseud])
      flash[:notice] += "Your imported stories have been orphaned. Thank you for leaving them in the archive! "
    elsif params[:imported_stories] == "delete"
      # delete the works
      @external_author.delete_works
      flash[:notice] += "Your imported stories have been deleted. "
    end
    @invitation.mark_as_redeemed if @invitation && !params[:imported_stories].blank?

    if @external_author.update_attributes(params[:external_author])
      flash[:notice] += "Your preferences have been saved."
      if @user
        redirect_to user_external_authors_path(@user)
      else
        redirect_to root_path
      end
    else
      flash[:error] += "There were problems saving your preferences."
      render :action => "edit" 
    end
  end
end
