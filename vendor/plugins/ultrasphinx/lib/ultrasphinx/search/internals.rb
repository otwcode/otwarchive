
module Ultrasphinx
  class Search
    module Internals
      include Associations

      # These methods are kept stateless to ease debugging
      
      private
      
      def build_request_with_options opts
      
        request = Riddle::Client.new
        request.instance_eval do          
          @server = Ultrasphinx::CLIENT_SETTINGS['server_host']
          @port = Ultrasphinx::CLIENT_SETTINGS['server_port']          
          @match_mode = :extended # Force extended query mode
          @offset = opts['per_page'] * (opts['page'] - 1)
          @limit = opts['per_page']
          @max_matches = [@offset + @limit, MAX_MATCHES].min
        end
          
        # Sorting
        sort_by = opts['sort_by']
        unless sort_by.blank?
          if opts['sort_mode'].to_s == 'relevance'
            # If you're sorting by a field you don't want 'relevance' order
            raise UsageError, "Sort mode 'relevance' is not valid with a sort_by field"
          end
          request.sort_by = sort_by.to_s
        end
        
        if sort_mode = SPHINX_CLIENT_PARAMS['sort_mode'][opts['sort_mode']]
          request.sort_mode = sort_mode
        else
          raise UsageError, "Sort mode #{opts['sort_mode'].inspect} is invalid"
        end        

        # Weighting
        weights = opts['weights']
        if weights.any?
          # Order according to the field order for Sphinx, and set the missing fields to 1.0
          ordered_weights = []
          Fields.instance.types.map do |name, type| 
            name if type == 'text'
          end.compact.sort.each do |name|
            ordered_weights << (weights[name] || 1.0)
          end
          request.weights = ordered_weights
        end
        
        # Class names
        unless Array(opts['class_names']).empty?
          request.filters << Riddle::Client::Filter.new(
            'class_id', 
            (opts['class_names'].map do |model| 
              MODELS_TO_IDS[model.to_s] or 
                MODELS_TO_IDS[model.to_s.constantize.base_class.to_s] or 
                raise UsageError, "Invalid class name #{model.inspect}"
            end), 
            false)
        end          

        # Extract raw filters 
        # XXX We should coerce based on the Field values, not on the class
        Array(opts['filters']).each do |field, value|          
          field = field.to_s
          type = Fields.instance.types[field]
          unless type
            raise UsageError, "field #{field.inspect} is invalid"
          end
          
          begin
            case value
              when Integer, Float, BigDecimal, NilClass, Array
                # XXX Hack to force floats to be floats
                value = value.to_f if type == 'float'
                # Just bomb the filter in there
                request.filters << Riddle::Client::Filter.new(field, Array(value), false)
              when Range
                # Make sure ranges point in the right direction
                min, max = [value.begin, value.end].map {|x| x._to_numeric }
                raise NoMethodError unless min <=> max and max <=> min
                min, max = max, min if min > max
                # XXX Hack to force floats to be floats
                min, max = min.to_f, max.to_f if type == 'float'
                request.filters << Riddle::Client::Filter.new(field, min..max, false)
              when String
                # XXX Hack to move text filters into the query
                opts['parsed_query'] << " @#{field} #{value}"
              else
                raise NoMethodError
            end
          rescue NoMethodError => e
            raise UsageError, "filter value #{value.inspect} for field #{field.inspect} is invalid"
          end
        end
        
        request
      end    
      
      def get_subtotals(original_request, query)
        request = original_request._deep_dup
        request.instance_eval { @filters.delete_if {|filter| filter.attribute == 'class_id'} }
        
        facets = get_facets(request, query, 'class_id')
        
        # Not using the standard facet caching here
        Hash[*(MODELS_TO_IDS.map do |klass, id|
          [klass, facets[id] || 0]
        end.flatten)]
      end
      
      def get_facets(original_request, query, original_facet)
        request, facet = original_request._deep_dup, original_facet        
        facet += "_facet" if Fields.instance.types[original_facet] == 'text'            
        
        unless Fields.instance.types[facet]
          if facet == original_facet
            raise UsageError, "Field #{original_facet} does not exist" 
          else
            raise UsageError, "Field #{original_facet} is a text field, but was not configured for text faceting"
          end
        end
        
        # Set the facet query parameter and modify per-page setting so we snag all the facets
        request.instance_eval do
          @group_by = facet
          @group_function = :attr
          @group_clauses = '@count desc'
          @offset = 0
          @limit = Ultrasphinx::Search.client_options['max_facets']
          @max_matches = [@limit, MAX_MATCHES].min
        end
        
        # Run the query
        begin
          matches = request.query(query, UNIFIED_INDEX_NAME)[:matches]
        rescue DaemonError
          raise ConfigurationError, "Index seems out of date. Run 'rake ultrasphinx:index'"
        end
                
        # Map the facets back to something sane
        facets = {}
        matches.each do |match|
          attributes = match[:attributes]
          raise DaemonError if facets[attributes['@groupby']]
          facets[attributes['@groupby']] = attributes['@count']
        end
                
        # Invert hash's, if we have them
        reverse_map_facets(facets, original_facet)
      end
      
      def reverse_map_facets(facets, facet) 
        facets = facets.dup
      
        if Fields.instance.types[facet] == 'text'        
          # Apply the map, rebuilding if the cache is missing or out-of-date
          facets = Hash[*(facets.map do |hash, value|
            rebuild_facet_cache(facet) unless FACET_CACHE[facet] and FACET_CACHE[facet].has_key?(hash)
            [FACET_CACHE[facet][hash], value]
          end.flatten)]
        end
        
        facets        
      end
      
      def rebuild_facet_cache(facet)
        # Cache the reverse hash map for the textual facet if it hasn't been done yet
        # XXX Not necessarily optimal since it requires a direct DB hit once per mongrel
        Ultrasphinx.say "caching hash reverse map for text facet #{facet}"
        
        configured_classes = Fields.instance.classes[facet].map do |klass|

          # Concatenates might not work well
          type, configuration = nil, nil
          MODEL_CONFIGURATION[klass.name].except('conditions').each do |_type, values| 
            type = _type
            configuration = values.detect { |this_field| this_field['as'] == facet }
            break if configuration
          end
                    
          unless configuration and configuration['facet']
            Ultrasphinx.say "model #{klass.name} has the requested '#{facet}' field, but it was not configured for faceting, and will be skipped"
            next
          end
          
          FACET_CACHE[facet] ||= {}
          
          # XXX This is a duplication of stuff already known in configure.rb, and ought to be cleaned up,
          # but that would mean we have to either parse the .conf or configure every time at boot

          field_string, join_string = case type
            when 'fields'
              [configuration['field'], ""]
            when 'include'
              # XXX Only handles the basic case. No test coverage.

              table_alias = configuration['table_alias']
              association_model = if configuration['class_name']
                configuration['class_name'].constantize
              else
                get_association_model(klass, configuration)
              end

              ["#{table_alias}.#{configuration['field']}", 
                (configuration['association_sql'] or "LEFT OUTER JOIN #{association_model.table_name} AS #{table_alias} ON #{table_alias}.#{klass.to_s.downcase}_id = #{klass.table_name}.#{association_model.primary_key}")
              ]
            when 'concatenate'
              # Wait for someone to complain before worrying about this
              raise "Concatenation text facets have not been implemented"
          end
          
          klass.connection.execute("SELECT #{field_string} AS value, #{SQL_FUNCTIONS[ADAPTER]['hash']._interpolate(field_string)} AS hash FROM #{klass.table_name} #{join_string} GROUP BY value").each do |value, hash|
            FACET_CACHE[facet][hash.to_i] = value
          end                            
          klass
        end

        configured_classes.compact!      
        raise ConfigurationError, "no classes were correctly configured for text faceting on '#{facet}'" if configured_classes.empty?      
        
        FACET_CACHE[facet]
      end 
            
      # Inverse-modulus map the Sphinx ids to the table-specific ids
      def convert_sphinx_ids(sphinx_ids)    
        number_of_models = IDS_TO_MODELS.size
        sphinx_ids.sort_by do |item| 
          item[:index]
        end.map do |item|
          class_name = IDS_TO_MODELS[item[:doc] % number_of_models]
          raise DaemonError, "Impossible Sphinx document id #{item[:doc]} in query result" unless class_name
          [class_name, item[:doc] / number_of_models]
        end
      end

      # Fetch them for real
      def reify_results(ids)
        results = []
        
        ids_hash = {}
        ids.each do |class_name, id|
          (ids_hash[class_name] ||= []) << id
        end
        
        ids.map {|ary| ary.first}.uniq.each do |class_name|
          klass = class_name.constantize
          
          method_choices = Ultrasphinx::Search.client_options['finder_methods']
          finder = if method_choices.size > 1
            method_choices.detect { |method_name| klass.respond_to? method_name }
          else
            method_choices.last
          end

          records = klass.send(finder, ids_hash[class_name])
          
          unless Ultrasphinx::Search.client_options['ignore_missing_records']
            if records.size != ids_hash[class_name].size
              missed_ids = ids_hash[class_name] - records.map(&:id)
              msg = if missed_ids.size == 1
                "Couldn't find #{class_name} with ID=#{missed_ids.first}"
              else
                "Couldn't find #{class_name.pluralize} with IDs: #{missed_ids.join(',')} (found #{records.size} results, but was looking for #{ids_hash[class_name].size})"
              end
              raise ActiveRecord::RecordNotFound, msg
            end
          end
          
          records.each do |record|
            results[ids.index([class_name, record.id])] = record
          end
        end
        
        # Add an accessor for global search rank for each record, if requested
        if self.class.client_options['with_global_rank']
          results.each_with_index do |result, index|
            if result
              global_index = per_page * (current_page - 1) + index
              result.instance_variable_get('@attributes')['result_index'] = global_index
            end
          end
        end
        
        results.compact!
        
        if ids.size - results.size > Ultrasphinx::Search.client_options['max_missing_records']
          # Never reached if Ultrasphinx::Search.client_options['ignore_missing_records'] is false due to raise
          raise ConfigurationError, "Too many results for this query returned ActiveRecord::RecordNotFound. The index is probably out of date" 
        end
        
        results        
      end  
      
      def perform_action_with_retries
        tries = 0
        begin
          yield
        rescue NoMethodError,
            Riddle::VersionError,
            Riddle::ResponseError,
            Errno::ECONNREFUSED, 
            Errno::ECONNRESET, 
            Errno::EPIPE => e
          tries += 1
          if tries <= Ultrasphinx::Search.client_options['max_retries']
            say "restarting query (#{tries} attempts already) (#{e})"            
            sleep(Ultrasphinx::Search.client_options['retry_sleep_time']) 
            retry
          else
            say "query failed"
            raise DaemonError, e.to_s
          end
        end
      end
      
      def strip_bogus_characters(s)
        # Used to remove some garbage before highlighting
        s.gsub(/<.*?>|\.\.\.|\342\200\246|\n|\r/, " ").gsub(/http.*?( |$)/, ' ') if s
      end
      
      def strip_query_commands(s)
        # XXX Hack for query commands, since Sphinx doesn't intelligently parse the query in excerpt mode
        # Also removes apostrophes in the middle of words so that they don't get split in two.
        s.gsub(/(^|\s)(AND|OR|NOT|\@\w+)(\s|$)/i, "").gsub(/(\w)\'(\w)/, '\1\2')
      end 
    
    end
  end  
end