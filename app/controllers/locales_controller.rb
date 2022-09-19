class LocalesController < ApplicationController

  def index
    authorize Locale

    @locales = Locale.default_order
  end

  def new
    authorize Locale

    @locale = Locale.new
    @languages = Language.default_order
  end

  # GET /locales/en/edit
  def edit
    authorize Locale

    @locale = Locale.find_by(iso: params[:id])
    @languages = Language.default_order
  end

  def update
    authorize Locale

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
    authorize Locale

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
