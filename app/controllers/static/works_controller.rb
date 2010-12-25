class Static::WorksController < Static::BaseController
  caches_page :show

  def show
    @work = Work.find(params[:id])
    if @work.restricted?
      access_denied and return
    end
    @chapters = @work.chapters.where(:posted => true).order(:position)
  end
end
