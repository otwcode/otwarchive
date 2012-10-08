class TechController < ApplicationController
  
  
  # GET /tech
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
