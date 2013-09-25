class BannedValuesController < ApplicationController
  before_filter :admin_only
  # GET /banned_values
  # GET /banned_values.json
  def index
    @banned_values = BannedValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @banned_values }
    end
  end

  # GET /banned_values/1
  # GET /banned_values/1.json
  def show
    @banned_value = BannedValue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @banned_value }
    end
  end

  # GET /banned_values/new
  # GET /banned_values/new.json
  def new
    @banned_value = BannedValue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @banned_value }
    end
  end

  # GET /banned_values/1/edit
  def edit
    @banned_value = BannedValue.find(params[:id])
  end

  # POST /banned_values
  # POST /banned_values.json
  def create
    @banned_value = BannedValue.new(params[:banned_value])

    respond_to do |format|
      if @banned_value.save
        format.html { redirect_to @banned_value, notice: 'Banned string was successfully created.' }
        format.json { render json: @banned_value, status: :created, location: @banned_value }
      else
        format.html { render action: "new" }
        format.json { render json: @banned_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /banned_values/1
  # PUT /banned_values/1.json
  def update
    @banned_value = BannedValue.find(params[:id])

    respond_to do |format|
      if @banned_value.update_attributes(params[:banned_value])
        format.html { redirect_to @banned_value, notice: 'Banned string was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @banned_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /banned_values/1
  # DELETE /banned_values/1.json
  def destroy
    @banned_value = BannedValue.find(params[:id])
    @banned_value.destroy

    respond_to do |format|
      format.html { redirect_to banned_values_url }
      format.json { head :no_content }
    end
  end
end
