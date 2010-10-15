class KnownIssuesController < ApplicationController
  
  before_filter :admin_only, :except => [:index]
  
  # GET /known_issues
  # GET /known_issues.xml
  def index
    @known_issues = KnownIssue.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @known_issues }
    end
  end

  # GET /known_issues/1
  # GET /known_issues/1.xml
  def show
    @known_issue = KnownIssue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @known_issue }
    end
  end

  # GET /known_issues/new
  # GET /known_issues/new.xml
  def new
    @known_issue = KnownIssue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @known_issue }
    end
  end

  # GET /known_issues/1/edit
  def edit
    @known_issue = KnownIssue.find(params[:id])
  end

  # POST /known_issues
  # POST /known_issues.xml
  def create
    @known_issue = KnownIssue.new(params[:known_issue])

    respond_to do |format|
      if @known_issue.save
        flash[:notice] = 'KnownIssue was successfully created.'
        format.html { redirect_to(@known_issue) }
        format.xml  { render :xml => @known_issue, :status => :created, :location => @known_issue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @known_issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /known_issues/1
  # PUT /known_issues/1.xml
  def update
    @known_issue = KnownIssue.find(params[:id])

    respond_to do |format|
      if @known_issue.update_attributes(params[:known_issue])
        flash[:notice] = 'KnownIssue was successfully updated.'
        format.html { redirect_to(@known_issue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @known_issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /known_issues/1
  # DELETE /known_issues/1.xml
  def destroy
    @known_issue = KnownIssue.find(params[:id])
    @known_issue.destroy

    respond_to do |format|
      format.html { redirect_to(known_issues_url) }
      format.xml  { head :ok }
    end
  end
end
