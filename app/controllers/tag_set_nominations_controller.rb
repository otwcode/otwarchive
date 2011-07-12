class TagSetNominationsController < ApplicationController
  before_filter :users_only
  before_filter :load_tag_set, :except => [ :index ]
  before_filter :load_nomination, :only => [:show, :edit, :destroy]
  
  def load_tag_set
    @tag_set = OwnedTagSet.find(params[:owned_tag_set_id])
    unless @tag_set
      flash[:notice] = ts("What tag set did you want to nominate for?")
      redirect_to tag_sets_path and return
    end
  end

  def load_nomination
    @tag_set_nomination = TagSetNomination.find(params[:id])
    unless @tag_set_nomination
      flash[:notice] = ts("Which nominations did you want to work with?")
      redirect_to user_tag_set_nominations_path(@user) and return
    end
  end
    
  def index
    @tag_set_nominations = TagSetNomination.all
  end

  def show
    @tag_set_nomination = TagSetNomination.find(params[:id])
  end

  def new
    @tag_set_nomination = TagSetNomination.new
  end

  def edit
    @tag_set_nomination = TagSetNomination.find(params[:id])
  end

  def create
    @tag_set_nomination = TagSetNomination.new(params[:tag_set_nomination])

    respond_to do |format|
      if @tag_set_nomination.save
        format.html { redirect_to(@tag_set_nomination, :notice => 'Tag set nomination was successfully created.') }
        format.xml  { render :xml => @tag_set_nomination, :status => :created, :location => @tag_set_nomination }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag_set_nomination.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tag_set_nominations/1
  # PUT /tag_set_nominations/1.xml
  def update
    @tag_set_nomination = TagSetNomination.find(params[:id])

    respond_to do |format|
      if @tag_set_nomination.update_attributes(params[:tag_set_nomination])
        format.html { redirect_to(@tag_set_nomination, :notice => 'Tag set nomination was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag_set_nomination.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tag_set_nominations/1
  # DELETE /tag_set_nominations/1.xml
  def destroy
    @tag_set_nomination = TagSetNomination.find(params[:id])
    @tag_set_nomination.destroy

    respond_to do |format|
      format.html { redirect_to(tag_set_nominations_url) }
      format.xml  { head :ok }
    end
  end
end
