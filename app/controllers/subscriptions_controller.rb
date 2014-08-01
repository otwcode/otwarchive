class SubscriptionsController < ApplicationController

  skip_before_filter :store_location, :only => [:create, :destroy]

  before_filter :users_only
  before_filter :load_user
  before_filter :check_ownership

  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end

  # GET /subscriptions
  # GET /subscriptions.xml
  def index
    @subscriptions = @user.subscriptions.includes(:subscribable)
    if params[:type].present?
      @subscriptions = @subscriptions.where(subscribable_type: params[:type].classify)
    end
    @subscriptions = @subscriptions.to_a.sort { |a,b| a.name.downcase <=> b.name.downcase }    
    @subscriptions = @subscriptions.paginate page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE
  end

  # POST /subscriptions
  # POST /subscriptions.xml
  def create
    @subscription = @user.subscriptions.build(params[:subscription])

    respond_to do |format|
      if @subscription.save
        format.html {
          flash[:notice] = ts("You are now following %{name}. If you'd like to stop receiving email updates, you can unsubscribe from <a href=\"#{user_subscriptions_url}\">your Subscriptions page</a>.", :name => @subscription.name).html_safe
          redirect_to request.referer || @subscription.subscribable
        }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.xml
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscribable = @subscription.subscribable
    @subscription.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = ts("You have successfully unsubscribed from %{name}.", :name => @subscription.name).html_safe
        redirect_to request.referer || user_subscriptions_path(current_user)
      }
    end
  end
end
