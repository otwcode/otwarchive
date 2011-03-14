class SubscriptionsController < ApplicationController
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
  end

  # POST /subscriptions
  # POST /subscriptions.xml
  def create
    @subscription = @user.subscriptions.build(params[:subscription])

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to(@subscription.subscribable, :notice => "You are now following #{@subscription.name}. 
        If you'd like to stop receiving email updates, you can return to this page and click 'Unsubscribe'.") }
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
      format.html { redirect_to(@subscribable, :notice => "You have successfully unsubscribed from #{@subscription.name}.") }
    end
  end
end
