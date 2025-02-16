module Departure
  module Migration
    # Make all connections in the connection pool NOT use PerconaAdapter instead of the current adapter.
    # Ref https://github.com/departurerb/departure/issues/110.
    def reconnect_with_percona
      ActiveRecord::Base.establish_connection(connection_config.merge(adapter: "percona"))
    end
  end
end

puts "WARNING: The monkeypatch #{__FILE__} was written for version 6.7.0 of the departure gem, but you are running #{Departure::VERSION}. Please update or remove the monkeypatch." unless Departure::VERSION == "6.7.0"
