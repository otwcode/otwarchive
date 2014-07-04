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
    subscriptions = @user.subscriptions.includes(:subscribable)

    # split the subscriptions by subscribable_type
    @sub_series, rest = subscriptions.partition{ |s| s.subscribable_type == "Series"}
    @sub_users, @sub_works = rest.partition{ |r| r.subscribable_type == "User"}

    # sort each subscription type array alphabetically
    @sub_series.sort! { |a,b| a.name.downcase <=> b.name.downcase }
    @sub_users.sort! { |a,b| a.name.downcase <=> b.name.downcase }
    @sub_works.sort! { |a,b| a.name.downcase <=> b.name.downcase }
  end

  # POST /subscriptions
  # POST /subscriptions.xml
  def create
    @subscription = @user.subscriptions.build(params[:subscription])

    respond_to do |format|
      if @subscription.save
        format.html {
          flash[:notice] = ts("You are now following %{name}. If you'd like to stop receiving email updates, you can unsubscribe from <a href=\"#{user_subscriptions_url}\">your Subscriptions page</a>.", :name => @subscription.name).html_safe
          # redirect_back_or_default(@subscription.subscribable) # it always returns to subscriptions rather than the subscribable
          redirect_to(@subscription.subscribable)
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
        redirect_back_or_default(@subscribable)
      }
    end
  end
end
