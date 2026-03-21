class PeopleController < ApplicationController
  before_action :load_collection

  def search
    if params[:people_search].blank?
      @search = PseudSearchForm.new({})
    else
      options = people_search_params.merge(page: params[:page])
      @search = PseudSearchForm.new(options)
      @people = @search.search_results.scope(:for_search)
      flash_search_warnings(@people)
    end
  end

  def index
    if @collection.present?
      @people = @collection.participants.with_attached_icon.includes(:user).order(:name).page(params[:page])
      @rec_counts = Pseud.rec_counts_for_pseuds(@people)
      @work_counts = Pseud.work_counts_for_pseuds(@people)
      @page_subtitle = t(".collection_page_title", collection_title: @collection.title)
    else
      redirect_to search_people_path
    end
  end

  private

  def people_search_params
    params.require(:people_search).permit(:query, :name, :collection_id, :fandom)
  end
end
