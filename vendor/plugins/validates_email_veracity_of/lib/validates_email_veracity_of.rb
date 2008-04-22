# Contains the actual logic behind the plugin.
class ValidatesEmailVeracityOf
  
  
  # Defines a server contains methods used to retrieve information from it.
  class Server
    
    attr_accessor :name
    
    def to_s #:nodoc:
      name
    end
    
    def initialize(name = '')
      self.name = name
    end
    
  end
  
  
  # Defines a domain and contains methods used to retrieve information from it such
  # as mail exchange and address server information.
  class Domain
    
    require 'resolv'
    require 'timeout'
    
    attr_accessor :name
    
    # Creates a new Domain object, optionally accepts a domain as an argument.
    # ==== Example
    # <tt>Domain.new('gmail.com').exchange_servers # => ["ms1.google.com",
    # "ms2.google.com", ...]</tt>
    def initialize(name = '')
      self.name = name
    end
    
    def to_s #:nodoc:
      name
    end
    
    # Returns an array of server objects for address server the domain's A record, if
    # the domain does not exist, it will return an empty array.  If it times out, nil
    # is returned.
    # ==== Options
    # * *timeout*
    #   - Sets a time (in seconds) that the method will time out and return nil.  The
    #     default is two.
    def address_servers(options = {})
      servers_in :address, options
    end
    
    # Returns an array of server objects for each exchange server in the domain's MX
    # record, if the domain does not exist, it will return an empty array. If it times
    # out, nil is returned.
    # ==== Options
    # * *timeout*
    #   - Sets a time (in seconds) that the method will time out and return nil.  The
    #     default is two.
    def exchange_servers(options = {})
      servers_in :exchange, options
    end
    
    protected
      # Returns an array of server objects from the domain using the specified method.
      # If the domain does not exist an empty array is returned.  If the process times
      # out, nil is returned.
      # ==== Arguments
      # * *record*
      #   - Either <tt>:exchange</tt> to return mail exchange servers (MX) or
      #     <tt>:address</tt> to return primary address servers (A)
      # ==== Options
      # * *timeout*
      #   - Sets a time (in seconds) that the method will time out and return nil.  The
      #     default is two.
      def servers_in(record, options = {})
        type = case record.to_s.downcase
          when 'exchange' : Resolv::DNS::Resource::IN::MX
          when 'address' : Resolv::DNS::Resource::IN::A
        end
        st = Timeout::timeout(options.fetch(:timeout, 2)) do
          Resolv::DNS.new.getresources(name, type).inject([]) do |servers, s|
            servers << Server.new(s.send(record).to_s)
          end
        end
       rescue Timeout::Error
        nil
      end
    
  end
  
  
  # Defines an email address and contains methods to perform things needed in order
  # to validate it.
  class EmailAddress
    
    attr_accessor :address
    
    # Creates a new EmailAddress object, optionally accepts an email address as an
    # argument.
    # ==== Example
    # <tt>EmailAddress.new('heycarsten@gmail.com').domain # => "gmail.com"</tt>
    def initialize(email = '')
      self.address = email
    end
    
    # Domains that we know have mail servers such as gmail.com, aol.com and
    # yahoo.com.
    def self.known_domains
      %w[ aol.com gmail.com hotmail.com mac.com msn.com
      rogers.com sympatico.ca yahoo.com ]
    end
    
    # Checks the email's domain against any invalid domains passed in the options
    # hash.  This is useful when you don't want addresses from providers such as
    # dodgeit.com.
    # ==== Options
    # * *invalid_domains*
    #   - An array of strings that indicate invalid domain names.
    # ==== Example
    # <tt>EmailAddress.new('carsten@dodgeit.com').domain_is_valid?(:invalid_domains => ['dodgeit.com']) # => false</tt>
    def domain_is_valid?(options = {})
      configuration = { :invalid_domains => nil }.update(options)
      return true unless configuration[:invalid_domains]
      unless configuration[:invalid_domains].is_a?(Array)
        raise ArgumentError, 'invalid_domains must be an Array'
      end
      !configuration[:invalid_domains].include?(domain.name.downcase)
    end
    
    # Returns the domain portion of the email address.
    # ==== Example
    # <tt>EmailAddress.new('heycarsten@gmail.com').domain # => "gmail.com"</tt>
    def domain
      Domain.new((address.split('@')[1] || '').strip)
    end
    
    # Verifies the email address for well-formedness against a well-known pattern.
    # Note that it will not verifiy all RFC 2822 valid addresses.
    def pattern_is_valid?
      address =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    end
    
    # Checks if the email address' domain has any servers in it's mail exchange (MX)
    # or address (A) records.  If it does then true is returned, otherwise false is
    # returned.  If the lookup times out, it will return false (or nil if the
    # :fail_on_timeout option is specified.)  Additionally the secondary (A record)
    # lookup can be turned off (if your really picky) by passing in the option
    # :mx_only => true.
    # ==== Options
    # * *mx_only*
    #   - The domain is only checked for the presence of mail exchange servers, the
    #     address record is ignored.
    # * *timeout*
    #   - Time (in seconds) before the domain lookup is skipped. Default is two.
    # * *fail_on_timeout*
    #   - Causes validation to fail if a timeout occurs.
    def domain_has_servers?(options = {})
      return true if EmailAddress.known_domains.include?(domain.name.downcase)
      servers = []
      servers << domain.exchange_servers(options)
      servers << domain.address_servers(options) if !options[:mx_only]
      servers.flatten!
      if (servers.size - servers.nitems) > 0
        options.fetch(:fail_on_timeout, true) ? nil : true
      else
        !servers.empty?
      end
    end
    
  end
  
  
end
