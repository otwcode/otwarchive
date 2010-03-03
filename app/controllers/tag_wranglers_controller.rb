class TagWranglersController < ApplicationController
  before_filter :check_user_status
	before_filter :check_permission

  def check_permission
    logged_in_as_admin? || permit?("tag_wrangler") || access_denied
  end 

  def index
    @wranglers = Role.find_by_name("tag_wrangler").users.alphabetical
    conditions = ["canonical = 1"]
    unless params[:fandom_string].blank?
      conditions.first << " AND name LIKE ?"
      conditions << params[:fandom_string] + "%"
    end
    if !params[:media_id].blank?
      @media = Media.find_by_name(params[:media_id])
      @assignments = @media.fandoms.find(:all, :select => 'tags.*, users.login AS wrangler', 
      :joins => "LEFT JOIN wrangling_assignments ON (wrangling_assignments.fandom_id = tags.id) 
      LEFT JOIN users ON (users.id = wrangling_assignments.user_id)", :conditions => conditions, :order => :name).paginate(:page => params[:page], :per_page => 50)
    elsif !params[:wrangler_id].blank? && params[:wrangler_id] == "No Wrangler"
      conditions.first << " AND users.id IS NULL"
      @assignments = Fandom.find(:all, :select => 'tags.*, users.login AS wrangler', 
      :joins => "LEFT JOIN wrangling_assignments ON (wrangling_assignments.fandom_id = tags.id) 
      LEFT JOIN users ON (users.id = wrangling_assignments.user_id)", :conditions => conditions, :order => :name).paginate(:page => params[:page], :per_page => 50)     
    elsif !params[:wrangler_id].blank?
      @wrangler = User.find_by_login(params[:wrangler_id])  
      @assignments = @wrangler.fandoms.find(:all, :select => 'tags.*, users.login AS wrangler', 
      :joins => "LEFT JOIN wrangling_assignments wa2 ON (wa2.fandom_id = tags.id) 
      LEFT JOIN users ON (users.id = wa2.user_id)", :conditions => conditions, :order => :name).paginate(:page => params[:page], :per_page => 50)     
    else
      @assignments = Fandom.find(:all, :select => 'tags.*, users.login AS wrangler', 
      :joins => "LEFT JOIN wrangling_assignments ON (wrangling_assignments.fandom_id = tags.id) 
      LEFT JOIN users ON (users.id = wrangling_assignments.user_id)", :conditions => conditions, :order => :name).paginate(:page => params[:page], :per_page => 50)
    end
  end

  def show
    @wrangler = User.find_by_login(params[:id])
    @fandoms = @wrangler.fandoms.by_name
    @counts = {}
    [Fandom, Character, Pairing, Freeform].each do |klass|
      @counts[klass.to_s.downcase.pluralize.to_sym] = klass.unwrangled.count
    end
  end
  
  def create
    unless params[:assignments].blank?
      params[:assignments].each_pair do |fandom_id, user_logins|
        fandom = Fandom.find(fandom_id)
        user_logins.uniq.each do |login|
          unless login.blank?
            user = User.find_by_login(login)
            unless user.nil? || user.fandoms.include?(fandom)
              assignment = user.wrangling_assignments.build(:fandom_id => fandom.id)
              assignment.save!
            end
          end
        end        
      end
      flash[:notice] = "Wranglers were successfully assigned!"
    end
    redirect_to tag_wranglers_path(:media_id => params[:media_id], :fandom_string => params[:fandom_string], :wrangler_id => params[:wrangler_id])    
  end
  
  def destroy
    wrangler = User.find_by_login(params[:id])
    assignment = WranglingAssignment.find(:first, :conditions => {:user_id => wrangler.id, :fandom_id => params[:fandom_id]})
    assignment.destroy
    redirect_to tag_wranglers_path    
  end
end