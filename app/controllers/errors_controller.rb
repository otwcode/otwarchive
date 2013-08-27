class ErrorsController < ApplicationController
  
  %w(403 404 422 500 502).each do |error_code|
    define_method error_code.to_sym do
      respond_to do |format|
        format.any(:html, :text, :pdf, :mobi, :epub) { render error_code, :status => error_code.to_i }
        format.all { render :nothing => true, :status => error_code.to_i }
      end
    end
  end
  
end
