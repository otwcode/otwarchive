class ExternalWorksController < ApplicationController
  before_filter :check_user_status, :only => [:new]
  
  def new
  end
  
  # Used with bookmark form to get an existing external work and return it via rjs
  def fetch
   if params['external_url']
     url = ExternalWork.format_url(params['external_url'])
     @external_work = ExternalWork.find(:first, :conditions => {:url => url})
   end  
  end  
  
end
