module SeriesHelper 
  
  def show_series_data(work)
    series_data = series_data_for_work(work)
    series_data.join(ArchiveConfig.DELIMITER_FOR_OUTPUT).html_safe
  end
  
  # this should only show prev and next works visible to the current user
  def series_data_for_work(work)
    series = work.series.select{|s| s.visible?(current_user)}
    series.map do |serial|
      serial_works = serial.serial_works.find(:all, :include => :work, :conditions => ['works.posted = ?', true], :order => :position).select{|sw| sw.work.visible(current_user)}.collect{|sw| sw.work}
      visible_position = serial_works.index(work) || serial_works.length     
      unless !visible_position
        previous_link = (visible_position > 0) ? link_to("&laquo; ".html_safe, serial_works[visible_position - 1]) : "".html_safe
        main_link = ("Part " + (visible_position+1).to_s + " of the " + link_to(serial.title, serial) + " series").html_safe
        next_link = (visible_position < serial_works.size-1) ? link_to(" &raquo;".html_safe, serial_works[visible_position + 1]) : "".html_safe
        previous_link + main_link + next_link
      end
    end
  end
  
  def work_series_description(work, series)
    serial = SerialWork.where(:work_id => work.id, :series_id => series.id).first
    ("Part <strong>#{serial.position}</strong> of " + link_to(series.title, series)).html_safe 
  end

  def series_list_for_feeds(work)
    series = work.series
    if series.empty?
      return "None"
    else
      list = []
      for s in series
        list << ts("Part %{serial_index} of %{link_to_series}", serial_index: s.serial_works.where(work_id: work.id).select(:position).first.position, link_to_series: link_to(s.title, series_url(s)))
      end
      return list.join(', ')
    end
  end
    
  # Generates confirmation message for 'remove me as author'
  def series_removal_confirmation(series, user)
    if !(series.work_pseuds & user.pseuds).empty?
      "You're listed as an author of works in this series. Do you want to remove yourself as an author of this series and all of its works?"
    else
      "Are you sure you want to be removed as an author of this series?"
    end
  end
  
end
