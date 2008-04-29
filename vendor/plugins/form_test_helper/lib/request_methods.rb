module FormTestHelper

  module RequestMethods 
    def make_request(method, path, params={}, referring_uri=nil, xhr=false)
      if self.kind_of?(ActionController::IntegrationTest) || self.kind_of?(ActionController::Integration::Session)
        make_integration_request(method, path, params, referring_uri, xhr)
      else
        make_normal_request(method, path, params, referring_uri, xhr)
      end
    end
    
    private
    
    def make_integration_request(method, path, params, referring_uri, xhr)
      if xhr
        params = {'_method' => method }.merge(params)
        xml_http_request :post, path, params
      else
        self.send(method, path, params.stringify_keys, {:referer => referring_uri})
      end
    end
    
    def make_normal_request(method, path, params, referring_uri, xhr)
      params.merge!(ActionController::Routing::Routes.recognize_path(path, :method => method))
      self.instance_eval("@request").env["HTTP_REFERER"] ||= referring_uri # facilitate testing of redirect_to :back
      if xhr
        self.xhr(method, params.delete(:action), params.stringify_keys)
      else
        self.send(method, params.delete(:action), params.stringify_keys)
      end
    end
    
  end
  
end