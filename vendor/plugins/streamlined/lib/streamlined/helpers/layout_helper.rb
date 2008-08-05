# These helpers are needed by the layout
# You might need to include them in non-streamlined controllers that want to share layout
module Streamlined::Helpers::LayoutHelper

  # Returns an array of arrays which define the side menus for the corresponding view.
  # Override all side menus in all Streamlined controllers by defining this method in
  # ApplicationHelper, or override on a controller by controller basis in their specific
  # helpers.
  # Each array should contain the text of the link and the URL parameters for the link.
  def streamlined_side_menus
    [
      ["TBD", {:action=>"list"}]
    ]
  end

  # Returns an array of arrays which define the top menus for the corresponding view.
  # Override all top menus in all Streamlined controllers by defining this method in
  # ApplicationHelper, or override on a controller by controller basis in their specific
  # helpers.
  # Each array should contain the text of the link and the URL parameters for the link.
  def streamlined_top_menus
    [
      ["TBD", {:action=>"new"}]
    ]
  end
  # TODO: move to REST or eliminate
  def streamlined_auto_discovery_link_tag
    # return if @syndication_type.nil? || @syndication_actions.nil?
    # 
    # if @syndication_actions.include? params[:action]
    #   "<link rel=\"alternate\" type=\"application/#{@syndication_type.downcase}+xml\" title=\"#{@syndication_type.upcase}\" href=\"#{params[:action]}/xml\" />"
    # end
  end
  def streamlined_branding
    link_to "Streamlined", "/"
  end

  def streamlined_footer
    <<-END
Brought to you by Streamlined (<a href="http://streamlinedframework.org/">StreamlinedFramework.org</a>)  
END
  end
end