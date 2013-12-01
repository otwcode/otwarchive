class OrphansController < ApplicationController
  # You must be logged in to orphan works - relies on current_user data 
  before_filter :users_only, :except => [:index, :about]
  
  before_filter :load_orphans, :except => [:index, :about]
  
  def index
    @user = User.orphan_account
    @works = @user.works
  end
  
  def load_orphans
    if params[:work_id]
      work = Work.find(params[:work_id])
      @pseuds = (current_user.pseuds & work.pseuds)
      @orphans = [work]
    elsif params[:work_ids]
      @orphans = Work.joins(:pseuds => :user).where("users.id = ?", current_user.id).where(:id => params[:work_ids]).readonly(false)
      @pseuds = current_user.pseuds & (@orphans.collect(&:pseuds).flatten)
    elsif params[:series_id]
      series = Series.find(params[:series_id])
      @pseuds = (current_user.pseuds & series.pseuds)
      @orphans = [series]            
    elsif params[:pseud_id]
      @pseuds = [Pseud.find(params[:pseud_id])]
      @orphans = @pseuds.first.works
    else 
      @pseuds = current_user.pseuds
      @orphans = current_user.works      
    end
    
    if @pseuds.empty?
      flash[:error] = ts("You don't have permission to orphan that!")
      redirect_to root_path and return
      false
    end
  end
    
  
  def new
  end
  
  def create
    new_orphans = {}
    use_default = params[:use_default] == "true"
    if !@pseuds.blank? && Creatorship.orphan(@pseuds, @orphans, use_default)
      flash[:notice] = ts('Orphaning was successful.')
      redirect_to(current_user)
    else
      flash[:error] = ts("You don't seem to have permission to orphan this.")
      redirect_to root_path
    end 
  end
  
end
