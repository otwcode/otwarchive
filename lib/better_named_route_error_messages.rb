# Awesomeness from http://pivots.pivotallabs.com/users/nick/blog/articles/360-helpful-named-route-error-messages
#
class ActionController::Routing::RouteSet
  # try to give a helpful error message when named route generation fails
  def raise_named_route_error(options, named_route, named_route_name)
    helpful_options = options.inject({}) {|hash, (key, value)| hash.merge(key => value.to_param) }
    diff = named_route.requirements.diff(options)
    unless diff.empty?
      raise RoutingError, "#{named_route_name}_url failed to generate  from #{helpful_options.inspect}, expected:  #{named_route.requirements.inspect}, diff:  #{named_route.requirements.diff(helpful_options).inspect}"
    else
      required_segments = named_route.segments.select {|seg| (!seg.optional?) && (!seg.is_a?(DividerSegment)) }
      required_keys_or_values = required_segments.map { |seg| seg.key rescue seg.value } # we want either the key or the value from the segment
      raise RoutingError, "#{named_route_name}_url failed to generate from #{helpful_options.inspect} - you may have ambiguous routes, or you may need to supply additional parameters for this route.  content_url has the following required parameters: #{required_keys_or_values.inspect} - are they all satisfied?"
    end
  end
end
