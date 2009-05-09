class SerialWorksController < ApplicationController
  
  before_filter :load_serial_work
  before_filter :check_ownership
    
  def load_serial_work
    @serial_work = SerialWork.find(params[:id])
    @check_ownership_of = @serial_work.series
  end

  # DELETE /related_works/1
  # DELETE /related_works/1.xml
  def destroy
    @serial_work.destroy
    redirect_to series_path(@serial_work.series)
  end
end
