class SubscriptionsController < ApplicationController

  before_action :users_only
  before_action :load_user
  before_action :load_subscribable_type, only: [:index, :confirm_delete_all, :delete_all]
  before_action :check_ownership

  def load_user
    @user = User.find_by(login: params[:user_id])
    @check_ownership_of = @user
  end

  # GET /subscriptions
  # GET /subscriptions.xml
  def index
    @subscriptions = @user.subscriptions.includes(:subscribable)
    @subscriptions = @subscriptions.where(subscribable_type: @subscribable_type.classify) if @subscribable_type

    @subscriptions = @subscriptions.to_a.sort { |a,b| a.name.downcase <=> b.name.downcase }
    @subscriptions = @subscriptions.paginate page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE
    @page_subtitle = @subscribable_type ? t(".subscription_type_page_title", username: @user.login, subscription_type: @subscribable_type.classify) : t(".page_title", username: @user.login)
  end

  # POST /subscriptions
  # POST /subscriptions.xml
  def create
    @subscription = @user.subscriptions.build(subscription_params)

    success_message = ts("You are now following %{name}. If you'd like to stop receiving email updates, you can unsubscribe from <a href=\"#{user_subscriptions_path}\">your Subscriptions page</a>.", name: @subscription.name).html_safe
    if @subscription.save
      respond_to do |format|
        format.html { redirect_back_or_to(@subscription.subscribable, notice: success_message) }
        format.json { render json: { item_id: @subscription.id, item_success_message: success_message }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          flash.keep
          redirect_back_or_to(@subscription.subscribable, flash: { error: @subscription.errors.full_messages })
        end
        format.json { render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.xml
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscribable = @subscription.subscribable
    @subscription.destroy

    success_message = ts("You have successfully unsubscribed from %{name}.", name: @subscription.name).html_safe
    respond_to do |format|
      format.html { redirect_back_or_to(user_subscriptions_path(current_user), notice: success_message) }
      format.json { render json: { item_success_message: success_message }, status: :ok }
    end
  end

  def confirm_delete_all
  end

  def delete_all
    @subscriptions = @user.subscriptions
    @subscriptions = @subscriptions.where(subscribable_type: @subscribable_type.classify) if @subscribable_type

    success = true
    @subscriptions.each do |subscription|
      subscription.destroy!
    rescue StandardError
      success = false
    end

    if success
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to user_subscriptions_path(current_user, type: @subscribable_type)
  end

  private

  def load_subscribable_type
    @subscribable_type = params[:type].pluralize.downcase if params[:type] && Subscription::VALID_SUBSCRIBABLES.include?(params[:type].singularize.titleize)
  end

  def subscription_params
    params.require(:subscription).permit(
      :subscribable_id, :subscribable_type
    )
  end

end
