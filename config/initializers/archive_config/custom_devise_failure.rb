class CustomDeviseFailure < Devise::FailureApp
  def recall
    flash.now[:error] = i18n_message(:invalid) if is_flashing_format?
    super
  end
end