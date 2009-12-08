class SearchController < ApplicationController

  def index
    # stuff goes here 
  end
  
  # POST /search
  def search
    unless @advanced_search.errors.empty?
      flash[:notice] = 'Errors'
      render :action => :index and return
    end  
    
    if params[:advanced_search_button]
      if @advanced_search.terms.blank?
          @advanced_search.errors.add_to_base("Updating: Please add all required tags. Fandom is missing.")
      end
      render :action => :results
    elsif params[:cancel_button]
      flash[:notice] = t('search_canceled', :default => "Search canceled.")

      redirect_to current_user
        
      
    end

  end
  
  def results
    flash[:notice] = 'Results page'
  end
  
end
