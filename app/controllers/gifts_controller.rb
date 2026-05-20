class GiftsController < ApplicationController
  before_action :load_collection

  def index
    @user = User.find_by!(login: params[:user_id]) if params[:user_id]
    @recipient_name = params[:recipient]
    authorize :gift, :access_refused? if params[:refused].present? && @user && logged_in_as_admin?
    @can_access_refused_gifts = @user && (@user == current_user || (logged_in_as_admin? && policy(:gift).access_refused?))
    @page_subtitle = t(".page_subtitle", name: (@user ? @user.login : @recipient_name))
    unless @user || @recipient_name
      flash[:error] = t(".whose_gifts_error")
      redirect_to(@collection || root_path) and return
    end

    if @user
      @works = @can_access_refused_gifts && params[:refused] ? @user.rejected_gift_works : @user.gift_works
    else
      pseud = Pseud.parse_byline(@recipient_name)
      @works = pseud ? pseud.gift_works : Work.giftworks_for_recipient_name(@recipient_name)
    end
    @works = if guest?
               @works.visible_to_all
             else
               @works.visible_to_registered_user
             end
    @works = @works.in_collection(@collection) if @collection
    @works = @works.order("revised_at DESC").paginate(page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE)
  end

  def toggle_rejected
    @gift = Gift.find(params[:id])
    # have to have the gift, be logged in, and the owner of the gift
    if @gift && current_user && @gift.user == current_user
      @gift.rejected = !@gift.rejected?
      @gift.save!
      flash[:notice] = if @gift.rejected?
                         t(".now_hidden_notice")
                       else
                         t(".now_visible_notice")
                       end
    else
      # user doesn't have permission
      access_denied
      return
    end
    redirect_to user_gifts_path(current_user) and return
  end
end
