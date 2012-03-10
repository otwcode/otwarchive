class ErrorsController < ApplicationController

  def method_not_allowed
    render :action => "403"
  end

  def forbidden
    render :action => "403"
  end
    
  def not_found
    render :action => "404"
  end
    
  def unprocessable_entity
    render :action => "422"
  end

  def internal_server_error
    render :action => "500"
  end

  def conflict
    render :action => "500"
  end
  
  def not_implemented
    render :action => "500"
  end
  
  %w(403 404 422 500 502).each do |error_code|
    define_method error_code.to_sym do
      respond_to do |format|
        format.html { render error_code, :status => error_code }
        format.any(:js) { head error_code }
      end
    end
  end
  
end
