# Fix for https://github.com/departurerb/departure/issues/110, where advisory locks are not released after migration
# is completed. This should be removed when a fix is available upstream.
module Departure
  class ConnectionBase < ActiveRecord::Base
    def self.establish_connection(config = nil)
      super
    end
  end

  class OriginalAdapterConnection < ConnectionBase; end
end

puts "WARNING: The monkeypatch #{__FILE__} was written for version 6.7.0 of the departure gem, but you are running #{Departure::VERSION}. Please update or remove the monkeypatch." unless Departure::VERSION == "6.7.0"
