module SeriesHelper 
  
  def show_series_data(work)
     work.serial_works.map do |sw|
       previous_link = !(@series_previous.blank? || @series_previous[sw.series.id].blank?) ? link_to("<< ", @series_previous[sw.series.id]) : ""
       main_link = "Part " + sw.position.to_s + " of the " + link_to(sw.series.title, sw.series) + " series"
      next_link = !(@series_next.blank? || @series_next[sw.series.id].blank?) ? link_to(" >>", @series_next[sw.series.id]) : ""
       '<li>' + previous_link + main_link + next_link + '</li>'
     end
  end
  
end
