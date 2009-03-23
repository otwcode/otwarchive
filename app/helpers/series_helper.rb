module SeriesHelper 
  
  def show_series_data(work)
    # this should only show prev and next works visible to the current user
    series = work.series.select{|s| s.visible?(current_user)}
    series.map do |serial|
      # cull visible works
      serial_works = serial.serial_works.find(:all, :include => :work, :conditions => ['works.posted = ?', true], :order => :position).select{|sw| sw.work.visible(current_user)}.collect{|sw| sw.work}
      visible_position = serial_works.index(work) if serial_works     
      unless !visible_position # is nil if work is a draft 
        previous_link = (visible_position > 0) ? link_to("<< ", serial_works[visible_position - 1]) : ""
        main_link = "Part " + (visible_position+1).to_s + " of the " + link_to(serial.title, serial) + " series"
        next_link = (visible_position < serial_works.size-1) ? link_to(" >>", serial_works[visible_position + 1]) : ""
        '<li>' + previous_link + main_link + next_link + '</li>'
      end
    end
  end
  
end
