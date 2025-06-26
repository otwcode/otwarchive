class ErrorsController < ApplicationController
  %w[403 404 422 500].each do |error_code|
    define_method error_code.to_sym do
      render error_code, status: error_code.to_i, formats: :html
    end
  end

  def auth_error
    @page_subtitle = t(".browser_title")
  end

  def timeout_error
    @page_subtitle = t(".browser_title")
    render "timeout_error", status: :gateway_timeout
  end
end
