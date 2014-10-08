class WranglingGuidelinesController < ApplicationController

  before_filter :admin_only, :except => [:index, :show]

  # GET /wrangling_guidelines
  def index
    @wrangling_guidelines = WranglingGuideline.order('position ASC')
  end

  # GET /wrangling_guidelines/1
  def show
    @wrangling_guideline = WranglingGuideline.find(params[:id])
  end

  # GET /wrangling_guidelines/new
  def new
    @wrangling_guideline = WranglingGuideline.new
  end

  # GET /wrangling_guidelines/1/edit
  def edit
    @wrangling_guideline = WranglingGuideline.find(params[:id])
  end

  # GET /wrangling_guidelines/manage
  def manage
    @wrangling_guidelines = WranglingGuideline.order('position ASC')
  end

  # POST /wrangling_guidelines
  def create
    @wrangling_guideline = WranglingGuideline.new(params[:wrangling_guideline])

    if @wrangling_guideline.save
      flash[:notice] = ts('Wrangling Guideline was successfully created.')
      redirect_to(@wrangling_guideline)
    else
      render :action => 'new'
    end
  end

  # PUT /wrangling_guidelines/1
  def update
    @wrangling_guideline = WranglingGuideline.find(params[:id])

    if @wrangling_guideline.update_attributes(params[:wrangling_guideline])
      flash[:notice] = ts('Wrangling Guideline was successfully updated.')
      redirect_to(@wrangling_guideline)
    else
      render :action => 'edit'
    end
  end

  # reorder FAQs
  def update_positions
    if params[:wrangling_guidelines]
      @wrangling_guidelines = WranglingGuideline.reorder(params[:wrangling_guidelines])       
      flash[:notice] = ts('Wrangling Guidelines order was successfully updated.')
    elsif params[:wrangling_guideline]
      params[:wrangling_guideline].each_with_index do |id, position|
        WranglingGuideline.update(id, :position => position + 1)
        (@wrangling_guidelines ||= []) << WranglingGuideline.find(id)
      end
    end
    redirect_to(wrangling_guidelines_path)
  end

  # DELETE /wrangling_guidelines/1
  def destroy
    @wrangling_guideline = WranglingGuideline.find(params[:id])
    @wrangling_guideline.destroy

    redirect_to(wrangling_guidelines_url)
  end
end