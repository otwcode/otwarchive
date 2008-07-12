module SeriesHelper 
  
  def show_series_data(work)
     work.serial_works.map do |sw|
       "Part " + sw.position.to_s + " of the " + link_to(sw.series.title, sw.series) + " series.<br />"
     end
  end
  
end
