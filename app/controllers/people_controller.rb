class PeopleController < ApplicationController

  before_action :load_collection

  # ES UPGRADE TRANSITION #
  # Remove and standardize
  def do_search
    options = { query: params[:query], page: params[:page] || 1 }
    if @collection
      options[:collection_id] = @collection.id
    end
    @people = PseudSearch.search(options)
    @rec_counts = Pseud.rec_counts_for_pseuds(@people)
    @work_counts = Pseud.work_counts_for_pseuds(@people)
  end

  def new_search
    if people_search_params.blank?
      @search = PseudSearchForm.new({})
    else
      options = people_search_params.merge(page: params[:page])
      @search = PseudSearchForm.new(options)
      @people = @search.search_results
      flash_max_search_results_notice(@people)
    end
  end

  def search
    if use_new_search?
      new_search and return
    elsif params[:query].present?
      do_search
    end
  end

  def index
    if @collection.present?
      @people = @collection.participants.order(:name).page(params[:page])
      @rec_counts = Pseud.rec_counts_for_pseuds(@people)
      @work_counts = Pseud.work_counts_for_pseuds(@people)
    else
      redirect_to search_people_path
    end
  end

  protected

  def people_search_params
    return {} unless params[:people_search].present?
    params[:people_search].permit!
  end
end
