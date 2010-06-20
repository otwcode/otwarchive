class OrphansController < ApplicationController
  # You must be logged in to orphan works - relies on current_user data 
  before_filter :users_only, :except => [:index, :about]
  
  def index
    @user = User.orphan_account
    @works = @user.works
  end
  
  def new
    @to_be_orphaned = if params[:work_id]
                        Work.find(params[:work_id])
                      elsif params[:series_id]
                        Series.find(params[:series_id])
                      elsif params[:pseud_id]
                        Pseud.find(params[:pseud_id])
                      else
                        current_user      
                      end
  end
  
  def create
    new_orphans = {}
    if params[:work_id]
      work = Work.find(params[:work_id])
      pseuds = (current_user.pseuds & work.pseuds)
      orphans = [work]
    elsif params[:series_id]
      series = Series.find(params[:series_id])
      pseuds = (current_user.pseuds & series.pseuds)
      orphans = [series]            
    elsif params[:pseud_id]
      pseuds = [Pseud.find(params[:pseud_id])]
      orphans = pseuds.first.works
    else 
      pseuds = current_user.pseuds
      orphans = current_user.works      
    end
    use_default = params[:use_default] == "true"
    if !pseuds.blank? && Creatorship.orphan(pseuds, orphans, use_default)
      flash[:notice] = t('success', :default => 'Orphaning was successful.')
      redirect_to(current_user)
    else
      render :action => :new 
    end 
  end
  
end
