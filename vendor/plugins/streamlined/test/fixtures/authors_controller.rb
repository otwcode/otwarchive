require "#{RAILS_ROOT}/app/controllers/application"
class AuthorsController < ApplicationController
	acts_as_streamlined
	layout "streamlined"  # need this to test markup in the layouts
	
#	# Demonstrates how to access instance from a subclass if needed
#	def access_instance
#	  self.instance
#    end
#  
#  # Demonstrates how to set instance from a subclass if needed
#  def show_special
#    self.crud_context = :show
#    self.instance = Poem.find(params[:id])
#    render_or_redirect(:success, 'show')    
#  end
end