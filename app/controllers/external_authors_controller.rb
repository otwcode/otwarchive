class ExternalAuthorsController < ApplicationController
  before_filter :load_user
  before_filter :check_ownership, :only => [:create, :edit, :destroy, :new, :update]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]

  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end

  def index
    @external_authors = @user.external_authors
  end

  def new
    @external_author = ExternalAuthor.new
    @user = current_user
    @external_author.external_author_names.build
  end

  def edit
    @external_author = ExternalAuthor.find(params[:id])
  end

  def create
    @external_author = ExternalAuthor.new(params[:external_author])
    if @user == current_user
      @external_author.is_claimed = true
      @external_author.user = @user
    end

    if @external_author.save
      flash[:notice] = 'ExternalAuthor was successfully created.'
      redirect_to user_external_authors_path(@user)
    else
      render :action => "new"
    end
  end

  def update
    @external_author = ExternalAuthor.find(params[:id])

    if @external_author.update_attributes(params[:external_author])
      flash[:notice] = 'ExternalAuthor was successfully updated.'
      redirect_to user_external_authors_path(@user)
    else
      render :action => "edit" 
    end
  end

  def destroy
    @external_author = ExternalAuthor.find(params[:id])
    @external_author.destroy

    redirect_to user_external_authors_path(@user)
  end
end
