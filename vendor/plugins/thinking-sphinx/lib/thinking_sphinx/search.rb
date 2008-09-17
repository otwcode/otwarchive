module ThinkingSphinx
  # Once you've got those indexes in and built, this is the stuff that
  # matters - how to search! This class provides a generic search
  # interface - which you can use to search all your indexed models at once.
  # Most times, you will just want a specific model's results - to search and
  # search_for_ids methods will do the job in exactly the same manner when
  # called from a model.
  # 
  class Search
    class << self
      # Searches for results that match the parameters provided. Will only
      # return the ids for the matching objects. See #search for syntax
      # examples.
      #
      def search_for_ids(*args)
        results, client = search_results(*args.clone)
        
        options = args.extract_options!
        page    = options[:page] ? options[:page].to_i : 1

        ThinkingSphinx::Collection.ids_from_results(results, page, client.limit, options)
      end

      # Searches through the Sphinx indexes for relevant matches. There's
      # various ways to search, sort, group and filter - which are covered
      # below.
      #
      # Also, if you have WillPaginate installed, the search method can be used
      # just like paginate. The same parameters - :page and :per_page - work as
      # expected, and the returned result set can be used by the will_paginate
      # helper.
      # 
      # == Basic Searching
      #
      # The simplest way of searching is straight text.
      # 
      #   ThinkingSphinx::Search.search "pat"
      #   ThinkingSphinx::Search.search "google"
      #   User.search "pat", :page => (params[:page] || 1)
      #   Article.search "relevant news issue of the day"
      #
      # If you specify :include, like in an #find call, this will be respected
      # when loading the relevant models from the search results.
      # 
      #   User.search "pat", :include => :posts
      #
      # == Advanced Searching
      #
      # Sphinx supports 5 different matching modes. By default Thinking Sphinx
      # uses :all, which unsurprisingly requires all the supplied search terms
      # to match a result.
      #
      # Alternative modes include:
      #
      #   User.search "pat allan", :match_mode => :any
      #   User.search "pat allan", :match_mode => :phrase
      #   User.search "pat | allan", :match_mode => :boolean
      #   User.search "@name pat | @username pat", :match_mode => :extended
      #
      # Any will find results with any of the search terms. Phrase treats the search
      # terms a single phrase instead of individual words. Boolean and extended allow
      # for more complex query syntax, refer to the sphinx documentation for further
      # details.
      #
      # == Searching by Fields
      # 
      # If you want to step it up a level, you can limit your search terms to
      # specific fields:
      # 
      #   User.search :conditions => {:name => "pat"}
      #
      # This uses Sphinx's extended match mode, unless you specify a different
      # match mode explicitly (but then this way of searching won't work). Also
      # note that you don't need to put in a search string.
      #
      # == Searching by Attributes
      #
      # Also known as filters, you can limit your searches to documents that
      # have specific values for their attributes. There are two ways to do
      # this. The first is one that works in all scenarios - using the :with
      # option.
      #
      #   ThinkingSphinx::Search.search :with => {:parent_id => 10}
      #
      # The second is only viable if you're searching with a specific model
      # (not multi-model searching). With a single model, Thinking Sphinx
      # can figure out what attributes and fields are available, so you can
      # put it all in the :conditions hash, and it will sort it out.
      # 
      #   Node.search :conditions => {:parent_id => 10}
      # 
      # Filters can be single values, arrays of values, or ranges.
      # 
      #   Article.search "East Timor", :conditions => {:rating => 3..5}
      #
      # == Excluding by Attributes
      #
      # Sphinx also supports negative filtering - where the filters are of
      # attribute values to exclude. This is done with the :without option:
      #
      #   User.search :without => {:role_id => 1}
      # 
      # == Sorting
      #
      # Sphinx can only sort by attributes, so generally you will need to avoid
      # using field names in your :order option. However, if you're searching
      # on a single model, and have specified some fields as sortable, you can
      # use those field names and Thinking Sphinx will interpret accordingly.
      # Remember: this will only happen for single-model searches, and only
      # through the :order option.
      #
      #   Location.search "Melbourne", :order => :state
      #   User.search :conditions => {:role_id => 2}, :order => "name ASC"
      #
      # Keep in mind that if you use a string, you *must* specify the direction
      # (ASC or DESC) else Sphinx won't return any results. If you use a symbol
      # then Thinking Sphinx assumes ASC, but if you wish to state otherwise,
      # use the :sort_mode option:
      #
      #   Location.search "Melbourne", :order => :state, :sort_mode => :desc
      #
      # Of course, there are other sort modes - check out the Sphinx
      # documentation[http://sphinxsearch.com/doc.html] for that level of
      # detail though.
      #
      # == Grouping
      # 
      # For this you can use the group_by, group_clause and group_function
      # options - which are all directly linked to Sphinx's expectations. No
      # magic from Thinking Sphinx. It can get a little tricky, so make sure
      # you read all the relevant
      # documentation[http://sphinxsearch.com/doc.html#clustering] first.
      # 
      # Yes this section will be expanded, but this is a start.
      #
      # == Geo/Location Searching
      #
      # Sphinx - and therefore Thinking Sphinx - has the facility to search
      # around a geographical point, using a given latitude and longitude. To
      # take advantage of this, you will need to have both of those values in
      # attributes. To search with that point, you can then use one of the
      # following syntax examples:
      # 
      #   Address.search "Melbourne", :geo => [1.4, -2.217]
      #   Address.search "Australia", :geo => [-0.55, 3.108],
      #     :latitude_attr => "latit", :longitude_attr => "longit"
      # 
      # The first example applies when your latitude and longitude attributes
      # are named any of lat, latitude, lon, long or longitude. If that's not
      # the case, you will need to explicitly state them in your search, _or_
      # you can do so in your model:
      #
      #   define_index do
      #     has :latit  # Float column, stored in radians
      #     has :longit # Float column, stored in radians
      #     
      #     set_property :latitude_attr   => "latit"
      #     set_property :longitude_attr  => "longit"
      #   end
      # 
      # Now, geo-location searching really only has an affect if you have a
      # filter, sort or grouping clause related to it - otherwise it's just a
      # normal search. To make use of the positioning difference, use the
      # special attribute "@geodist" in any of your filters or sorting or grouping
      # clauses.
      # 
      # And don't forget - both the latitude and longitude you use in your
      # search, and the values in your indexes, need to be stored as a float in radians,
      # _not_ degrees. Keep in mind that if you do this conversion in SQL
      # you will need to explicitly declare a column type of :float.
      #
      #   define_index do
      #     has 'RADIANS(lat)', :as => :lat,  :type => :float
      #     # ...
      #   end
      # 
      def search(*args)
        results, client = search_results(*args.clone)
        
        ::ActiveRecord::Base.logger.error(
          "Sphinx Error: #{results[:error]}"
        ) if results[:error]
        
        options = args.extract_options!
        klass   = options[:class]
        page    = options[:page] ? options[:page].to_i : 1
        
        ThinkingSphinx::Collection.create_from_results(results, page, client.limit, options)
      end

      def count(*args)
        results, client = search_results(*args.clone)
        results[:total] || 0
      end

      # Checks if a document with the given id exists within a specific index.
      # Expected parameters:
      #
      # - ID of the document
      # - Index to check within
      # - Options hash (defaults to {})
      # 
      # Example:
      # 
      #   ThinkingSphinx::Search.search_for_id(10, "user_core", :class => User)
      # 
      def search_for_id(*args)
        options = args.extract_options!
        client  = client_from_options options
        
        query, filters    = search_conditions(
          options[:class], options[:conditions] || {}
        )
        client.filters   += filters
        client.match_mode = :extended unless query.empty?
        client.id_range   = args.first..args.first
        
        begin
          return client.query(query, args[1])[:matches].length > 0
        rescue Errno::ECONNREFUSED => err
          raise ThinkingSphinx::ConnectionError, "Connection to Sphinx Daemon (searchd) failed."
        end
      end
      
      private
      
      # This method handles the common search functionality, and returns both
      # the result hash and the client. Not super elegant, but it'll do for
      # the moment.
      # 
      def search_results(*args)
        options = args.extract_options!
        client  = client_from_options options
        
        query, filters    = search_conditions(
          options[:class], options[:conditions] || {}
        )
        client.filters   += filters
        client.match_mode = :extended unless query.empty?
        query             = args.join(" ") + query
        
        set_sort_options! client, options
        
        client.limit  = options[:per_page].to_i if options[:per_page]
        page          = options[:page] ? options[:page].to_i : 1
        client.offset = (page - 1) * client.limit

        begin
          ::ActiveRecord::Base.logger.debug "Sphinx: #{query}"
          results = client.query query
          ::ActiveRecord::Base.logger.debug "Sphinx Result: #{results[:matches].collect{|m| m[:attributes]["sphinx_internal_id"]}.inspect}"
        rescue Errno::ECONNREFUSED => err
          raise ThinkingSphinx::ConnectionError, "Connection to Sphinx Daemon (searchd) failed."
        end
        
        return results, client
      end
      
      # Set all the appropriate settings for the client, using the provided
      # options hash.
      # 
      def client_from_options(options = {})
        config = ThinkingSphinx::Configuration.new
        client = Riddle::Client.new config.address, config.port
        klass  = options[:class]
        index_options = klass ? klass.indexes.last.options : {}
        
        [
          :max_matches, :match_mode, :sort_mode, :sort_by, :id_range,
          :group_by, :group_function, :group_clause, :group_distinct, :cut_off,
          :retry_count, :retry_delay, :index_weights, :rank_mode,
          :max_query_time, :field_weights, :filters, :anchor, :limit
        ].each do |key|
          client.send(
            key.to_s.concat("=").to_sym,
            options[key] || index_options[key] || client.send(key)
          )
        end
        
        options[:classes] = [klass] if klass
        
        client.anchor = anchor_conditions(klass, options) || {} if client.anchor.empty?
        
        client.filters << Riddle::Client::Filter.new(
          "sphinx_deleted", [0]
        )
        
        # class filters
        client.filters << Riddle::Client::Filter.new(
          "class_crc", options[:classes].collect { |k| k.to_crc32s }.flatten
        ) if options[:classes]
        
        # normal attribute filters
        client.filters += options[:with].collect { |attr,val|
          Riddle::Client::Filter.new attr.to_s, filter_value(val)
        } if options[:with]
        
        # exclusive attribute filters
        client.filters += options[:without].collect { |attr,val|
          Riddle::Client::Filter.new attr.to_s, filter_value(val), true
        } if options[:without]
        
        client
      end
      
      def filter_value(value)
        case value
        when Range
          value.first.is_a?(Time) ? value.first.to_i..value.last.to_i : value
        when Array
          value.collect { |val| val.is_a?(Time) ? val.to_i : val }
        else
          Array(value)
        end
      end
      
      # Translate field and attribute conditions to the relevant search string
      # and filters.
      # 
      def search_conditions(klass, conditions={})
        attributes = klass ? klass.indexes.collect { |index|
          index.attributes.collect { |attrib| attrib.unique_name }
        }.flatten : []
        
        search_string = ""
        filters       = []
        
        conditions.each do |key,val|
          if attributes.include?(key.to_sym)
            filters << Riddle::Client::Filter.new(
              key.to_s, filter_value(val)
            )
          else
            search_string << "@#{key} #{val} "
          end
        end
        
        return search_string, filters
      end
      
      # Return the appropriate latitude and longitude values, depending on
      # whether the relevant attributes have been defined, and also whether
      # there's actually any values.
      # 
      def anchor_conditions(klass, options)
        attributes = klass ? klass.indexes.collect { |index|
          index.attributes.collect { |attrib| attrib.unique_name }
        }.flatten : []
        
        lat_attr = klass ? klass.indexes.collect { |index|
          index.options[:latitude_attr]
        }.compact.first : nil
        
        lon_attr = klass ? klass.indexes.collect { |index|
          index.options[:longitude_attr]
        }.compact.first : nil
        
        lat_attr = options[:latitude_attr] if options[:latitude_attr]
        lat_attr ||= :lat       if attributes.include?(:lat)
        lat_attr ||= :latitude  if attributes.include?(:latitude)
        
        lon_attr = options[:longitude_attr] if options[:longitude_attr]
        lon_attr ||= :lon       if attributes.include?(:lon)
        lon_attr ||= :long      if attributes.include?(:long)
        lon_attr ||= :longitude if attributes.include?(:longitude)
        
        lat = options[:lat]
        lon = options[:lon]
        
        if options[:geo]
          lat = options[:geo].first
          lon = options[:geo].last
        end
        
        lat && lon ? {
          :latitude_attribute   => lat_attr.to_s,
          :latitude             => lat,
          :longitude_attribute  => lon_attr.to_s,
          :longitude            => lon
        } : nil
      end
      
      # Set the sort options using the :order key as well as the appropriate
      # Riddle settings.
      # 
      def set_sort_options!(client, options)
        klass = options[:class]
        fields = klass ? klass.indexes.collect { |index|
          index.fields.collect { |field| field.unique_name }
        }.flatten : []
        
        case order = options[:order]
        when Symbol
          client.sort_mode = :attr_asc if client.sort_mode == :relevance || client.sort_mode.nil?
          if fields.include?(order)
            client.sort_by = order.to_s.concat("_sort")
          else
            client.sort_by = order.to_s
          end
        when String
          client.sort_mode = :extended
          client.sort_by   = sorted_fields_to_attributes(order, fields)
        else
          # do nothing
        end
        
        client.sort_mode = :attr_asc  if client.sort_mode == :asc
        client.sort_mode = :attr_desc if client.sort_mode == :desc
      end
      
      # Search through a collection of fields and translate any appearances
      # of them in a string to their attribute equivalent for sorting.
      # 
      def sorted_fields_to_attributes(string, fields)
        fields.each { |field|
          string.gsub!(/(^|\s)#{field}(,?\s|$)/) { |match|
            match.gsub field.to_s, field.to_s.concat("_sort")
          }
        }
        
        string
      end
    end
  end
end
