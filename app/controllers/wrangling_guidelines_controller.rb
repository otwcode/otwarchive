class WranglingGuidelinesController < ApplicationController
  include WranglingHelper
  
  before_action :admin_only, except: [:index, :show]

  # GET /wrangling_guidelines
  def index
    @wrangling_guidelines = WranglingGuideline.order("position ASC")
  end

  # GET /wrangling_guidelines/1
  def show
    @wrangling_guideline = WranglingGuideline.find(params[:id])
  end

  # GET /wrangling_guidelines/new
  def new
    authorize :wrangling if logged_in_as_admin?
    @wrangling_guideline = WranglingGuideline.new
  end

  # GET /wrangling_guidelines/1/edit
  def edit
    authorize :wrangling if logged_in_as_admin?
    @wrangling_guideline = WranglingGuideline.find(params[:id])
  end

  # GET /wrangling_guidelines/manage
  def manage
    authorize :wrangling if logged_in_as_admin?
    @wrangling_guidelines = WranglingGuideline.order("position ASC")
  end

  # POST /wrangling_guidelines
  def create
    authorize :wrangling if logged_in_as_admin?
    @wrangling_guideline = WranglingGuideline.new(wrangling_guideline_params)

    if @wrangling_guideline.save
      flash[:notice] = t("wrangling_guidelines.create")
      redirect_to(@wrangling_guideline)
    else
      render action: "new"
    end
  end

  # PUT /wrangling_guidelines/1
  def update
    authorize :wrangling if logged_in_as_admin?
    @wrangling_guideline = WranglingGuideline.find(params[:id])

    if @wrangling_guideline.update(wrangling_guideline_params)
      flash[:notice] = t("wrangling_guidelines.update")
      redirect_to(@wrangling_guideline)
    else
      render action: "edit"
    end
  end

  # reorder FAQs
  def update_positions
    authorize :wrangling if logged_in_as_admin?
    if params[:wrangling_guidelines]
      @wrangling_guidelines = WranglingGuideline.reorder_list(params[:wrangling_guidelines])
      flash[:notice] = t("wrangling_guidelines.reorder")
    end
    redirect_to(wrangling_guidelines_path)
  end

  # DELETE /wrangling_guidelines/1
  def destroy
    authorize :wrangling if logged_in_as_admin?
    @wrangling_guideline = WranglingGuideline.find(params[:id])
    @wrangling_guideline.destroy
    flash[:notice] = t("wrangling_guidelines.delete")
    redirect_to(wrangling_guidelines_path)
  end

  private

  def wrangling_guideline_params
    params.require(:wrangling_guideline).permit(:title, :content)
  end
end
