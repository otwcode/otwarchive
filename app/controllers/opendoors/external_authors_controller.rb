class Opendoors::ExternalAuthorsController < ApplicationController
  
  before_filter :users_only
  before_filter :opendoors_only
  before_filter :load_external_author, :only => [:show, :edit, :update, :forward]
  
  def load_external_author
    @external_author = ExternalAuthor.find(params[:id])
  end
  
  def index
    if params[:query]
      @query = params[:query]
      sql_query = '%' + @query +'%'
      @external_authors = ExternalAuthor.joins(:external_author_names).
        where("external_authors.email LIKE ? OR external_author_names.name LIKE ?", sql_query, sql_query).
        select("distinct external_authors.*")
    else
      @external_authors = ExternalAuthor.unclaimed      
    end    
    # list in reverse order
    @external_authors = @external_authors.order("created_at DESC").paginate(:page => params[:page])
  end
  
  def show
  end
  
  # create an external author identity and pre-emptively block it
  def create
    @external_author = ExternalAuthor.new(:email => params[:email], :do_not_import => true)
    unless @external_author.save
      flash[:error] = ts("We couldn't save that address.")
    else
      flash[:notice] = ts("We have saved and blocked the email address #{params[:email]}")
    end
    
    redirect_to opendoors_tools_path
  end
  
  def forward
    @email = params[:email]        
    @invitation = Invitation.where(:external_author_id => @external_author.id)
    
    # if there is no invite we create one
    unless @invitation      
      @invitation = Invitation.new(:external_author => @external_author)
    end
    
    @invitation.invitee_email = @email
    @invitation.creator = User.find_by_login("open_doors") || current_user
    if @invitation.save
      flash[:notice] = ts("Invitation sent to #{@email}!")
    else
      flash[:error] = ts("We couldn't forward to that email address.") + @invitation.errors.full_messages.join(", ")
    end
  end
  
  
end