class Static::WorksController < Static::BaseController
  caches_page :show

  def show
    @work = Work.find(params[:id])
    if @work.restricted?
      access_denied and return
    end
    @chapters = @work.chapters.where(:posted => true).order(:position)
    @page_title = get_page_title(@work.fandoms.size > 3 ? ts("Multifandom") : @work.fandoms.string,
      @work.anonymous? ?  ts("Anonymous")  : @work.pseuds.sort.collect(&:byline).join(', '),
      @work.title)
  end
end
