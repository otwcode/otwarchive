class GiftsController < ApplicationController
  
  before_filter :load_collection
  
  def index
    @user = User.find_by_login(params[:user_id]) if params[:user_id]
    @recipient_name = params[:recipient]
    unless @user || @recipient_name || @collection
      flash[:error] = t('gifts.whose', :default => "Whose gifts did you want to see?")
      redirect_to root_path and return
    end
    if @user || @recipient_name
      if @user
        @gifts = @user.gifts
      else
        @gifts = Gift.find_all_by_recipient_name(@recipient_name)
      end
      @works = @gifts.collect(&:work).uniq
      @works = (@works & @collection.approved_works) if @collection && (@user || @recipient_name)
    elsif @collection
      # only moderators can see
      if !@collection.user_is_maintainer?(current_user)
        flash[:error] = t('gifts.not_maintainer', :default => "Only maintainers can see gifts in a collection, sorry!")
        redirect_to root_path and return
      end
      @gifts = Gift.in_collection(@collection).include_pseuds
      @recipient_names = @gifts.collect(&:recipient_name)
      @has_received = {}
      @gifts.each do |gift|
        @has_received[gift.id] = gift.work.pseuds.map {|pseud| (@recipient_names.include?(pseud.name) || @recipient_names.include?(pseud.byline)) ? 'Y' : 
                (pseud.user.pseuds.collect {|p| [p.name, p.byline]}.flatten & @recipient_names).empty? ? 'N' : 'M*'}.join(", ")
      end
      @gifts = @gifts.sort_by {|gift| @has_received[gift.id]}
      render :index_for_collection
    end
  end
  
end
