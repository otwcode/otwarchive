class OrphansController < ApplicationController
  
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
    pseuds = current_user.pseuds
    if params[:work_id]
      pseuds = current_user.pseuds
      works = [Work.find(params[:work_id])]      
    elsif params[:pseud_id]
      pseuds = [Pseud.find(params[:pseud_id])]
      works = pseuds.first.works
    else 
      pseuds = current_user.pseuds
      works = current_user.works      
    end
    if !pseuds.blank? && !works.blank? && Creatorship.orphan(pseuds, works)
      flash[:notice] = 'Orphaning was successful.'.t
      redirect_to(current_user)
    else
      render :action => :new 
    end 
  end
  
end
