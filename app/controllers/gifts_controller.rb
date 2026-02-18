class GiftsController < ApplicationController
  before_action :load_collection

  def index
    @user = User.find_by!(login: params[:user_id]) if params[:user_id]
    @recipient_name = params[:recipient]
    @can_view_refused_gifts = can_view_refused_gifts?
    @page_subtitle = t("gifts.index.page_subtitle", name: (@user ? @user.login : @recipient_name))
    unless @user || @recipient_name
      flash[:error] = t("gifts.index.whose_gifts_error")
      redirect_to(@collection || root_path) and return
    end

    if @user
      @works = if guest?
                 @user.gift_works.visible_to_all
               elsif @can_view_refused_gifts && params[:refused]
                 @user.rejected_gift_works.visible_to_registered_user
               else
                 @user.gift_works.visible_to_registered_user
               end
    else
      pseud = Pseud.parse_byline(@recipient_name)
      @works = if pseud
                 guest? ? pseud.gift_works.visible_to_all : pseud.gift_works.visible_to_registered_user
               else
                 guest? ? Work.giftworks_for_recipient_name(@recipient_name).visible_to_all : Work.giftworks_for_recipient_name(@recipient_name).visible_to_registered_user
               end
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
                         t("gifts.toggle_rejected.now_hidden_notice")
                       else
                         t("gifts.toggle_rejected.now_visible_notice")
                       end
    else
      # user doesn't have permission
      access_denied
      return
    end
    redirect_to user_gifts_path(current_user) and return
  end

  private

  def can_view_refused_gifts?
    @user && (@user == current_user || admin_can_view_refused_gifts?)
  end

  def admin_can_view_refused_gifts?
    return false unless logged_in_as_admin? && current_admin

    (current_admin.roles & %w[policy_and_abuse superadmin]).present?
  end
end
