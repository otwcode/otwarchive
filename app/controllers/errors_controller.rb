class ErrorsController < ApplicationController
  
  %w[403 404 422 500].each do |error_code|
    define_method error_code.to_sym do
      respond_to do |format|
        format.all { render error_code, status: error_code.to_i, formats: :html, content_type: "text/html" }
      end
    end
  end

  def auth_error
    @page_subtitle = "Auth Error"
  end
  
end
