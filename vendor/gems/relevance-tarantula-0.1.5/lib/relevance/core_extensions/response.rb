# dynamically mixed in to response objects
module Relevance::CoreExtensions::Response 
  def html?                                           
    # some versions of Rails integration tests don't set content type
    # so we are treating nil as html. A better fix would be welcome here.
    ((content_type =~ %r{^text/html}) != nil)  || content_type == nil
  end
end

