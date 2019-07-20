class LocalesController < ApplicationController
  before_action :check_permission, only: [:new, :create, :update, :edit]

  def check_permission
    logged_in_as_admin? || permit?("translation_admin") || access_denied
  end

  def index
    @locales = Locale.default_order
  end

  def new
    @locale = Locale.new
    @languages = Language.default_order
  end

  # GET /locales/en/edit
  def edit
    @locale = Locale.find_by(iso: params[:id])
    @languages = Language.default_order
  end

  def update
    @locale = Locale.find_by(iso: params[:id])
    @locale.attributes = locale_params
    if @locale.save
      flash[:notice] = ts('Your locale was successfully updated.')
      redirect_to action: 'index', status: 303
    else
      @languages = Language.default_order
      render action: "edit"
    end
  end


  def create
    @locale = Locale.new(locale_params)
    if @locale.save
      flash[:notice] = t('successfully_added', default: 'Locale was successfully added.')
      redirect_to locales_path
    else
      @languages = Language.default_order
      render action: "new"
    end
  end

  private

  def locale_params
    params.require(:locale).permit(
      :name, :iso, :language_id, :email_enabled, :interface_enabled
    )
  end
end
