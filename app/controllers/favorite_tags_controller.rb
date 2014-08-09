class FavoriteTagsController < ApplicationController
  # GET /favorite_tags
  # GET /favorite_tags.json
  def index
    @favorite_tags = FavoriteTag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @favorite_tags }
    end
  end

  # GET /favorite_tags/1
  # GET /favorite_tags/1.json
  def show
    @favorite_tag = FavoriteTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @favorite_tag }
    end
  end

  # GET /favorite_tags/new
  # GET /favorite_tags/new.json
  def new
    @favorite_tag = FavoriteTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @favorite_tag }
    end
  end

  # GET /favorite_tags/1/edit
  def edit
    @favorite_tag = FavoriteTag.find(params[:id])
  end

  # POST /favorite_tags
  # POST /favorite_tags.json
  def create
    @favorite_tag = FavoriteTag.new(params[:favorite_tag])

    respond_to do |format|
      if @favorite_tag.save
        format.html { redirect_to @favorite_tag, notice: 'Favorite tag was successfully created.' }
        format.json { render json: @favorite_tag, status: :created, location: @favorite_tag }
      else
        format.html { render action: "new" }
        format.json { render json: @favorite_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /favorite_tags/1
  # PUT /favorite_tags/1.json
  def update
    @favorite_tag = FavoriteTag.find(params[:id])

    respond_to do |format|
      if @favorite_tag.update_attributes(params[:favorite_tag])
        format.html { redirect_to @favorite_tag, notice: 'Favorite tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @favorite_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favorite_tags/1
  # DELETE /favorite_tags/1.json
  def destroy
    @favorite_tag = FavoriteTag.find(params[:id])
    @favorite_tag.destroy

    respond_to do |format|
      format.html { redirect_to favorite_tags_url }
      format.json { head :no_content }
    end
  end
end
