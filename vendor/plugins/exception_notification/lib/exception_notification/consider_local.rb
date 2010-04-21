#This didn't belong on ExceptionNotifier and made backtraces worse.  To keep original functionality in place
#'ActionController::Base.send :include, ExceptionNotification::ConsiderLocal' or just include in your controller
module ExceptionNotification::ConsiderLocal
  module ClassMethods
    def self.included(target)
      require 'ipaddr'
      target.extend(ClassMethods)
    end
    
    def consider_local(*args)
      local_addresses.concat(args.flatten.map { |a| IPAddr.new(a) })
    end

    def local_addresses
      addresses = read_inheritable_attribute(:local_addresses)
      unless addresses
        addresses = [IPAddr.new("127.0.0.1")]
        write_inheritable_attribute(:local_addresses, addresses)
      end
      addresses
    end
  end
  
private
  
  def local_request?
    remote = IPAddr.new(request.remote_ip)
    !self.class.local_addresses.detect { |addr| addr.include?(remote) }.nil?
  end
  
end