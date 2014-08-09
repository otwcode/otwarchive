class ArchiveFaqsController < ApplicationController

  before_filter :admin_only, :except => [:index, :show]
  before_filter :set_locale, :only => [:index, :show]
  #before_filter :get_faq_translations, :only => [:new, :create, :edit, :update, :update_positions]

  #def get_faq_translations
  #  @translatable_faqs = ArchiveFaq.non_translated.order("created_at ASC")
  #end

  # GET /archive_faqs
  # GET /archive_faqs.xml
  def index
    @archive_faqs = ArchiveFaq.order('position ASC')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @archive_faqs }
    end
  end

  # GET /archive_faqs/1
  # GET /archive_faqs/1.xml
  def show
    @archive_faq = ArchiveFaq.find(params[:id])
    @page_subtitle = @archive_faq.title + ts(" FAQ")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @archive_faq }
    end
  end

  protected
  def build_questions
    notice = ""
    num_to_build = params["num_questions"] ? params["num_questions"].to_i : @archive_faq.questions.count
    if num_to_build < @archive_faq.questions.count
      notice += ts("There are currently %{num} questions. You can only submit a number equal to or greater than %{num}. ", :num => @archive_faq.questions.count)
      num_to_build = @archive_faq.questions.count
    elsif params["num_questions"]
      notice += ts("Set up %{num} questions. ", :num => num_to_build)
    end
    num_existing = @archive_faq.questions.count
    num_existing.upto(num_to_build-1) do
      @archive_faq.questions.build
    end
    unless notice.blank?
      flash[:notice] = notice
    end
  end

  public
  # GET /archive_faqs/new
  # GET /archive_faqs/new.xml
  def new
    @archive_faq = ArchiveFaq.new
    1.times { @archive_faq.questions.build}
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @archive_faq }
    end
  end

  # GET /archive_faqs/1/edit
  def edit
    @archive_faq = ArchiveFaq.find(params[:id])
    build_questions
  end

  # GET /archive_faqs/manage
  def manage
    @archive_faqs = ArchiveFaq.order('position ASC')

    #if params[:language_id].present? && (@language = Language.find_by_short(params[:language_id]))
     # @archive_faqs = @archive_faqs.where(:language_id => @language.id)
    #else
    #  @archive_faqs = @archive_faqs.non_translated
    #end
  end

  # POST /archive_faqs
  # POST /archive_faqs.xml
  def create
    @archive_faq = ArchiveFaq.new(params[:archive_faq])
    respond_to do |format|
      if @archive_faq.save
        flash[:notice] = 'ArchiveFaq was successfully created.'
        format.html { redirect_to(@archive_faq) }
        format.xml  { render :xml => @archive_faq, :status => :created, :location => @archive_faq }
        if @archive_faq.email_translations? && @archive_faq.new_record?
          AdminMailer.created_faq(@archive_faq.id, current_admin.login).deliver
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @archive_faq.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /archive_faqs/1
  # PUT /archive_faqs/1.xml
  def update
    @archive_faq = ArchiveFaq.find(params[:id])
    respond_to do |format|
      if @archive_faq.update_attributes(params[:archive_faq])
        flash[:notice] = 'ArchiveFaq was successfully updated.'
        format.html { redirect_to(@archive_faq) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @archive_faq.errors, :status => :unprocessable_entity }
      end
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

  # GET /archive_faqs/1/confirm_delete
  def confirm_delete
    @archive_faq = ArchiveFaq.find(params[:id])
  end

  # DELETE /archive_faqs/1
  # DELETE /archive_faqs/1.xml
  def destroy
    @archive_faq = ArchiveFaq.find(params[:id])
    @archive_faq.destroy

    respond_to do |format|
      format.html { redirect_to(archive_faqs_url) }
      format.xml  { head :ok }
    end
  end
end
