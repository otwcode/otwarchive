class ArchiveFaqsController < ApplicationController

  before_filter :admin_only, :except => [:index, :show]

  # GET /archive_faqs
  def index
    @archive_faqs = ArchiveFaq.order('position ASC')
  end

  # GET /archive_faqs/1
  def show
    @archive_faq = ArchiveFaq.find(params[:id])
  end

  # GET /archive_faqs/new
  def new
    @archive_faq = ArchiveFaq.new
  end

  # GET /archive_faqs/1/edit
  def edit
    @archive_faq = ArchiveFaq.find(params[:id])
  end

  # GET /archive_faqs/manage
  def manage
    @archive_faqs = ArchiveFaq.order('position ASC')
  end

  # POST /archive_faqs
  def create
    @archive_faq = ArchiveFaq.new(params[:archive_faq])

    if @archive_faq.save
      flash[:notice] = 'Archive FAQ was successfully created.'
      redirect_to(@archive_faq)
    else
      render :action => "new"
    end
  end

  # PUT /archive_faqs/1
  def update
    @archive_faq = ArchiveFaq.find(params[:id])

    if @archive_faq.update_attributes(params[:archive_faq])
      flash[:notice] = 'Archive FAQ was successfully updated.'
      redirect_to(@archive_faq)
    else
      render :action => "edit"
    end
  end

  # reorder FAQs
  def update_positions
    if params[:archive_faqs]
      @archive_faqs = ArchiveFaq.reorder(params[:archive_faqs])
      flash[:notice] = ts("Archive FAQs order was successfully updated.")
    elsif params[:archive_faq]
      params[:archive_faq].each_with_index do |id, position|
        ArchiveFaq.update(id, :position => position + 1)
        (@archive_faqs ||= []) << ArchiveFaq.find(id)
      end
    end
    respond_to do |format|
      format.html { redirect_to(archive_faqs_path) }
      format.js { render :nothing => true }
    end
  end

  # DELETE /archive_faqs/1
  def destroy
    @archive_faq = ArchiveFaq.find(params[:id])
    @archive_faq.destroy
    redirect_to(archive_faqs_url)
  end
end
