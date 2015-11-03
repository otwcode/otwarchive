class KnownIssuesController < ApplicationController

  before_filter :admin_only, :except => [:index]

  # GET /known_issues
  def index
    @known_issues = KnownIssue.all
  end

  # GET /known_issues/1
  def show
    @known_issue = KnownIssue.find(params[:id])
  end

  # GET /known_issues/new
  def new
    @known_issue = KnownIssue.new
  end

  # GET /known_issues/1/edit
  def edit
    @known_issue = KnownIssue.find(params[:id])
  end

  # POST /known_issues
  def create
    @known_issue = KnownIssue.new(params[:known_issue])

    if @known_issue.save
      flash[:notice] = 'Known issue was successfully created.'
      redirect_to(@known_issue)
    else
      render :action => "new"
    end
  end

  # PUT /known_issues/1
  def update
    @known_issue = KnownIssue.find(params[:id])

    if @known_issue.update_attributes(params[:known_issue])
      flash[:notice] = 'Known issue was successfully updated.'
      redirect_to(@known_issue)
    else
      render :action => "edit"
    end
  end

  # DELETE /known_issues/1
  def destroy
    @known_issue = KnownIssue.find(params[:id])
    @known_issue.destroy
    redirect_to(known_issues_url)
  end
end
