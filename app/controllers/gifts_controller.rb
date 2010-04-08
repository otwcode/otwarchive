class GiftsController < ApplicationController
  
  before_filter :load_collection
  
  def index
    @user = User.find_by_login(params[:user_id]) if params[:user_id]
    @recipient_name = params[:recipient]
    unless @user || @recipient_name || @collection
      flash[:error] = t('gifts.whose', :default => "Whose gifts did you want to see?")
      redirect_to root_path and return
    end
    if @user
      @gifts = @user.gifts
    else
      pseud = Pseud.parse_byline(@recipient_name, :assume_matching_login => true).first
      if pseud
        @gifts = pseud.gifts
      else
        @gifts = Gift.for_recipient_name(@recipient_name)
      end
    end
    @works = @gifts.collect(&:work).uniq.select {|w| w.visible?}
    @works = (@works & @collection.approved_works) if @collection && (@user || @recipient_name)
  end
  
end
