class GiftsController < ApplicationController
  
  before_filter :load_collection
  
  def index
    @user = User.find_by_login(params[:user_id]) if params[:user_id]
    @recipient_name = params[:recipient]
    @page_subtitle = ts("for %{name}", :name => (@user ? @user.login : @recipient_name))
    unless @user || @recipient_name
      flash[:error] = ts("Whose gifts did you want to see?")
      redirect_to(@collection || root_path) and return
    end
    if @user
      if current_user.nil?
        @works = @user.gift_works.visible_to_all_ordered_date_desc
      else
        @works = @user.gift_works.visible_to_registered_user_ordered_date_desc
      end
    else
      pseud = Pseud.parse_byline(@recipient_name, :assume_matching_login => true).first
      if pseud
        if current_user.nil?
          @works = pseud.gift_works.visible_to_all_ordered_date_desc
        else
          @works = pseud.gift_works.visible_to_registered_user_ordered_date_desc
        end
      else
        if current_user.nil?
          @works = Work.giftworks_for_recipient_name(@recipient_name).visible_to_all_ordered_date_desc
        else
          @works = Work.giftworks_for_recipient_name(@recipient_name).visible_to_registered_user
        end
      end
    end
    @works = (@works & @collection.approved_works) if @collection && (@user || @recipient_name)
  end
  
end
