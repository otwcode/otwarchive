class Opendoors::ToolsController < ApplicationController
  
  before_filter :users_only
  before_filter :opendoors_only
  
  def index
  
  end
  
  # Update the imported_from_url value on an existing AO3 work
  # This is not RESTful but is IMO a better idea than setting up a works controller under the opendoors namespace,
  # since the functionality we want to provide is so limited.
  def url_update
    if params[:work_url] && URI.parse(params[:work_url]) 
      if params[:work_url].match(/works\/([0-9]+)\/?$/)
        work_id = $1
        @work = Work.find(work_id)
      end
    end
    unless @work
      flash[:error] = ts("We couldn't find that work on the archive. Have you put in the full url?")
      redirect_to :action => :index and return
    end
    
    if params[:imported_from_url] && URI.parse(params[:imported_from_url])
      @imported_from_url = params[:imported_from_url]

      # check for any other works 
      works = Work.where(:imported_from_url => @imported_from_url)
      if works.count > 0 
      else
        # ok let's try to update
        @work.update_attribute(:imported_from_url, @imported_from_url)
        flash[:notice] = "Updated imported-from url for #{@work.title} to #{@imported_from_url}"
      end
    else
      flash[:error] = ts("The imported-from url you are trying to set doesn't seem valid.")
    end
    
    redirect_to :action => :index
  end
  
end