module SeriesHelper

  def show_series_data(work)
    series_data = series_data_for_work(work)
    series_data.join(ArchiveConfig.DELIMITER_FOR_OUTPUT).html_safe
  end

  # this should only show prev and next works visible to the current user
  def series_data_for_work(work)
    series = work.series.select { |s| s.visible?(current_user) }
    series.map do |serial|
      serial_works = serial.serial_works.
                           find(:all,
                                include: :work,
                                conditions: ['works.posted = ?', true],
                                order: :position).
                           select { |sw| sw.work.visible(current_user) }.
                     map(&:work)
      visible_position = serial_works.index(work) || serial_works.length
      unless !visible_position
        # Span used at end of previous_link and beginning of next_link to prevent extra
        # whitespace around main_link if next or previous link is missing. It also allows
        # us to use CSS to insert a decorative divider
        divider_span = content_tag(:span, " ", class: "divider")
        # This is empty if there is no previous work, otherwise it is
        # <a href class="previous">Previous Work</a><span class="divider"> </span>
        # with a left-pointing arrow before "Previous"
        previous_link = if visible_position > 0
                          link_to(ts("&#8592; Previous Work").html_safe,
                                  serial_works[visible_position - 1],
                                  class: "previous") + divider_span
                        else
                          "".html_safe
                        end
        # This part is always included
        # <span class="title">Part # of the <a href>TITLE</a> series</a></span>
        main_link = content_tag(:span,
                                ts("Part %{position} of the %{series_title} series",
                                   position: (visible_position + 1).to_s,
                                   series_title: link_to(serial.title, serial)).html_safe,
                                class: "title")
        # This is empty if there is no next work, otherwise it is
        # <span class="divider"> </span><a href class="next">Next Work</a>
        # with a right-pointing arrow after "Work"
        next_link = if visible_position < serial_works.size - 1
                      divider_span + link_to(ts("Next Work &#8594;").html_safe,
                                             serial_works[visible_position + 1],
                                             class: "next")
                    else
                      "".html_safe
                    end
        # put the parts together and wrap them in <span class="series">
        content_tag(:span, previous_link + main_link + next_link, class: "series")
      end
    end
  end

  def work_series_description(work, series)
    serial = SerialWork.where(:work_id => work.id, :series_id => series.id).first
    ts("Part <strong>#{serial.position}</strong> of #{link_to(series.title, series)}").html_safe
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
