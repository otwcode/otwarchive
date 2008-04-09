require 'uri'
require 'openid/extensions/sreg'
require 'openid/store/filesystem'

module OpenIdAuthentication
  OPEN_ID_AUTHENTICATION_DIR = RAILS_ROOT + "/tmp/openids"

  def self.store
    @@store
  end

  def self.store=(value)
    @@store = value
  end

  self.store = :db

  def store
    OpenIdAuthentication.store
  end

  class InvalidOpenId < StandardError
  end

  class Result
    ERROR_MESSAGES = {
      :missing      => "Sorry, the OpenID server couldn't be found",
      :canceled     => "OpenID verification was canceled",
      :failed       => "OpenID verification failed",
      :setup_needed => "OpenID verification needs setup"
    }

    def self.[](code)
      new(code)
    end

    def initialize(code)
      @code = code
    end

    def ===(code)
      if code == :unsuccessful && unsuccessful?
        true
      else
        @code == code
      end
    end

    ERROR_MESSAGES.keys.each { |state| define_method("#{state}?") { @code == state } }

    def successful?
      @code == :successful
    end

    def unsuccessful?
      ERROR_MESSAGES.keys.include?(@code)
    end

    def message
      ERROR_MESSAGES[@code]
    end
  end

  def self.normalize_url(url)
    uri = URI.parse(url.to_s.strip)
    uri = URI.parse("http://#{uri}") unless uri.scheme
    uri.scheme = uri.scheme.downcase  # URI should do this
    uri.normalize.to_s
  rescue URI::InvalidURIError
    raise InvalidOpenId.new("#{url} is not an OpenID URL")
  end

  protected
    def normalize_url(url)
      OpenIdAuthentication.normalize_url(url)
    end

    # The parameter name of "openid_url" is used rather than the Rails convention "open_id_url"
    # because that's what the specification dictates in order to get browser auto-complete working across sites
    def using_open_id?(identity_url = params[:openid_url]) #:doc:
      !identity_url.blank? || params[:open_id_complete]
    end

    def authenticate_with_open_id(identity_url = params[:openid_url], options = {}, &block) #:doc:
      if params[:open_id_complete].nil?
        begin_open_id_authentication(normalize_url(identity_url), options, &block)
      else
        complete_open_id_authentication(&block)
      end
    end

  private
    def begin_open_id_authentication(identity_url, options = {})
      return_to = options.delete(:return_to)
      open_id_request = open_id_consumer.begin(identity_url)
      add_simple_registration_fields(open_id_request, options)
      redirect_to(open_id_redirect_url(open_id_request, return_to))
    rescue OpenID::OpenIDError, Timeout::Error => e
      logger.error("[OPENID] #{e}")
      yield Result[:missing], identity_url, nil
    end

    def complete_open_id_authentication
      params_with_path = params.reject { |key, value| request.path_parameters[key] }
      params_with_path.delete(:format)
      open_id_response = timeout_protection_from_identity_server { open_id_consumer.complete(params_with_path, requested_url) }
      identity_url     = normalize_url(open_id_response.endpoint.claimed_id) if open_id_response.endpoint.claimed_id

      case open_id_response.status
      when OpenID::Consumer::SUCCESS
        yield Result[:successful], identity_url, OpenID::SReg::Response.from_success_response(open_id_response)
      when OpenID::Consumer::CANCEL
        yield Result[:canceled], identity_url, nil
      when OpenID::Consumer::FAILURE
        yield Result[:failed], identity_url, nil
      when OpenID::Consumer::SETUP_NEEDED
        yield Result[:setup_needed], open_id_response.setup_url, nil
      end
    end

    def open_id_consumer
      OpenID::Consumer.new(session, open_id_store)
    end

    def open_id_store
      case store
      when :db
        OpenIdAuthentication::DbStore.new
      when :file
        OpenID::FilesystemStore.new(OPEN_ID_AUTHENTICATION_DIR)
      else
        raise "Unknown store: #{store}"
      end
    end

    def add_simple_registration_fields(open_id_request, fields)
      sreg_request = OpenID::SReg::Request.new
      sreg_request.request_fields(Array(fields[:required]).map(&:to_s), true) if fields[:required]
      sreg_request.request_fields(Array(fields[:optional]).map(&:to_s), false) if fields[:optional]
      sreg_request.policy_url = fields[:policy_url] if fields[:policy_url]
      open_id_request.add_extension(sreg_request)
    end

    def open_id_redirect_url(open_id_request, return_to = nil)
      open_id_request.return_to_args['open_id_complete'] = '1'
      open_id_request.redirect_url(root_url, return_to || requested_url)
    end

    def requested_url
      "#{request.protocol + request.host_with_port + request.relative_url_root + request.path}"
    end

    def timeout_protection_from_identity_server
      yield
    rescue Timeout::Error
      Class.new do
        def status
          OpenID::FAILURE
        end

        def msg
          "Identity server timed out"
        end
      end.new
    end
end
