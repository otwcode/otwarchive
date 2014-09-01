class ArchiveFaqsController < ApplicationController

  before_filter :admin_only, :except => [:index, :show]
  before_filter :default_url_options


  # GET /archive_faqs
  def index
    @archive_faqs = ArchiveFaq.order('position ASC')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @archive_faqs }
    end
  end

  # GET /archive_faqs/1
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
  def new
    @archive_faq = ArchiveFaq.new
    1.times { @archive_faq.questions.build(attributes: { question: "This is a temporary question", content: "This is temporary content", anchor: "ThisIsATemporaryAnchor"})}
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
  end

  # POST /archive_faqs
  def create
    @archive_faq = ArchiveFaq.new(params[:archive_faq])
      if @archive_faq.save
        flash[:notice] = 'ArchiveFaq was successfully created.'
        redirect_to(@archive_faq)
        if @archive_faq.email_translations? && @archive_faq.new_record?
          AdminMailer.created_faq(@archive_faq.id, current_admin.login).deliver
        end
      else
        render :action => "new"
      end
  end

  # PUT /archive_faqs/1
  def update
    @archive_faq = ArchiveFaq.find(params[:id])
      if @archive_faq.update_attributes(params[:archive_faq])
        flash[:notice] = 'ArchiveFaq was successfully updated.'
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


  # The ?language_id=somelanguage needs to persist throughout URL changes
  def default_url_options(options={})
    I18n.locale = params[:language_id] if params[:language_id].present?
    if I18n.locale.present?
      params[:language_id] = I18n.locale
    end
    { language_id: I18n.locale }
  end

  # GET /archive_faqs/1/confirm_delete
  def confirm_delete
    @archive_faq = ArchiveFaq.find(params[:id])
  end

  # DELETE /archive_faqs/1
  def destroy
    @archive_faq = ArchiveFaq.find(params[:id])
    @archive_faq.destroy
    redirect_to(archive_faqs_url)
  end
end
