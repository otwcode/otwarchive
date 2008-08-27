module SeriesHelper 
  
  def show_series_data(work)
     work.serial_works.map do |sw|
       "Part ".t + sw.position.to_s + " of the ".t + link_to(sw.series.title, sw.series) + " series".t + "<br />"
     end
  end
  
end
