# Controller for Serial Works
# Last Updated 11/1/13
class SerialWorksController < ApplicationController
  
  before_filter :load_serial_work
  before_filter :check_ownership
    
  def load_serial_work
    @serial_work = SerialWork.find(params[:id])
    @check_ownership_of = @serial_work.series
  end

  # DELETE /related_works/1
  # DELETE /related_works/1.xml
  # Updated so if last work in series is deleted redirects to current user works listing instead of throwing 404
  # Stephanie 11/1/2013
  def destroy
    last_work = true
    if @serial_work.series.works.count > 1
      last_work = false
    end

    @serial_work.destroy

    if last_work = true
      redirect_to current_user
    else
      redirect_to series_path(@serial_work.series)
    end

  end
end
