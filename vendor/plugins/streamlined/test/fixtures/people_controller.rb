require "#{RAILS_ROOT}/app/controllers/application"
class PeopleController < ApplicationController
	acts_as_streamlined
	layout "streamlined"  # need this to test markup in the layouts
	
	# Demonstrates how to access instance from a subclass if needed
	def access_instance
	  self.instance
  end
  
  # Demonstrates how to set instance from a subclass if needed
  def show_special
    self.crud_context = :show
    self.instance = Person.find(params[:id])
    render_or_redirect(:success, 'show')    
  end
  
  # Re-raise errors caught by the controller
  def rescue_action(e); raise e; end
end