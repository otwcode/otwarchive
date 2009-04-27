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
                      elsif params[:pseud_id]
                        Pseud.find(params[:pseud_id])
                      else
                        current_user      
                      end
  end
  
  def create
    if params[:work_id]
      work = Work.find(params[:work_id])
      pseuds = (current_user.pseuds & work.pseuds)
      works = [work]      
    elsif params[:pseud_id]
      pseuds = [Pseud.find(params[:pseud_id])]
      works = pseuds.first.works
    else 
      pseuds = current_user.pseuds
      works = current_user.works      
    end
    use_default = params[:use_default] == "true"
    if !pseuds.blank? && !works.blank? && Creatorship.orphan(pseuds, works, use_default)
      flash[:notice] = t('success', :default => 'Orphaning was successful.')
      redirect_to(current_user)
    else
      render :action => :new 
    end 
  end
  
end
