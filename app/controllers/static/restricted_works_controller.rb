class Static::RestrictedWorksController < Static::BaseController
  before_filter :require_login
  #caches_action :index, :show

  def index
    @works = Work.in_collection(@collection).where(:restricted => true).order(:title)
  end

  def show
    @work = Work.find(params[:id])
    @chapters = @work.chapters.where(:posted => true).order(:position)
    render :action => 'static/works/show'
  end

  def require_login  
    logged_in? || logged_in_as_admin? || access_denied
  end
end
