
module Ultrasphinx
  class Configure  
    class << self

      include Associations
  
      # Force all the indexed models to load and register in the MODEL_CONFIGURATION hash.
      def load_constants
  
        Dir.chdir "#{RAILS_ROOT}/app/models/" do
          Dir["**/*.rb"].each do |filename|
            open(filename) do |file| 
              begin
                if file.grep(/^\s+is_indexed/).any?
                  filename = filename[0..-4]
                  begin                
                    File.basename(filename).camelize.constantize
                  rescue NameError => e
                    filename.camelize.constantize
                  end
                end
              rescue Object => e
                say "warning: possibly critical autoload error on #{filename}"
                say e.inspect
                #say e.backtrace.join("\n") if RAILS_ENV == "development"
              end
            end 
          end
        end
  
        # Build the field-to-type mappings.
        Fields.instance.configure(MODEL_CONFIGURATION)
      end
      
                    
      # Main SQL builder.
      def run       

        load_constants
              
        say "rebuilding configurations for #{RAILS_ENV} environment" 
        say "available models are #{MODEL_CONFIGURATION.keys.to_sentence}"
        File.open(CONF_PATH, "w") do |conf|
        
          conf.puts global_header            
          sources = []
          
          say "generating SQL"
          cached_groups = Fields.instance.groups.join("\n")
          MODEL_CONFIGURATION.each_with_index do |model_options, class_id|
            model, options = model_options
            klass, source = model.constantize, model.tableize.gsub('/', '__')   
            sources << source
            conf.puts build_source(Fields.instance, model, options, class_id, klass, source, cached_groups)
          end
          
          conf.puts build_index(sources)
        end              
      end
      
      
      ######
      
      private
      
      def global_header
        ["\n# Auto-generated at #{Time.now}.",
         "# Hand modifications will be overwritten.",
         "# #{BASE_PATH}\n",
         INDEXER_SETTINGS._to_conf_string('indexer'),
         DAEMON_SETTINGS._to_conf_string("searchd")]
      end      
      
      
      def setup_source_database(klass)
        # Supporting Postgres now
        connection_settings = klass.connection.instance_variable_get("@config")

        adapter_defaults = DEFAULTS[ADAPTER]
        raise ConfigurationError, "Unsupported database adapter" unless adapter_defaults

        conf = [adapter_defaults]                  
        connection_settings.reverse_merge(CONNECTION_DEFAULTS).each do |key, value|
          conf << "#{CONFIG_MAP[key]} = #{value}" if CONFIG_MAP[key]          
        end                 
        conf.sort.join("\n")
      end
      
      
      def setup_source_arrays(klass, fields, class_id, conditions)        
        condition_strings = Array(conditions).map do |condition| 
          "(#{condition})"
        end
        
        column_strings = [
          "(#{klass.table_name}.#{klass.primary_key} * #{MODEL_CONFIGURATION.size} + #{class_id}) AS id", 
          "#{class_id} AS class_id", "'#{klass.name}' AS class"]
        remaining_columns = fields.types.keys - ["class", "class_id"]        
        [column_strings, [], condition_strings, [], false, remaining_columns]
      end
      
      
      def range_select_string(klass)
        ["sql_query_range = SELECT",
          SQL_FUNCTIONS[ADAPTER]['range_cast']._interpolate("MIN(#{klass.primary_key})"),
          ", ",
          SQL_FUNCTIONS[ADAPTER]['range_cast']._interpolate("MAX(#{klass.primary_key})"),
          "FROM #{klass.table_name}"
        ].join(" ")
      end
      
      
      def query_info_string(klass, class_id)
        "sql_query_info = SELECT * FROM #{klass.table_name} WHERE #{klass.table_name}.#{klass.primary_key} = (($id - #{class_id}) / #{MODEL_CONFIGURATION.size})"
      end      
      
            
      def build_source(fields, model, options, class_id, klass, source, groups)
                
        column_strings, join_strings, condition_strings, group_bys, use_distinct, remaining_columns = 
          setup_source_arrays(
            klass, fields, class_id, options['conditions'])

        column_strings, join_strings, group_bys, remaining_columns = 
          build_regular_fields(
            klass, fields, options['fields'], column_strings, join_strings, group_bys, remaining_columns)
            
        column_strings, join_strings, group_bys, remaining_columns = 
          build_includes(
            klass, fields, options['include'], column_strings, join_strings, group_bys, remaining_columns)
            
        column_strings, join_strings, group_bys, use_distinct, remaining_columns = 
          build_concatenations(
            klass, fields, options['concatenate'], column_strings, join_strings, group_bys, use_distinct, remaining_columns)
        
        column_strings = add_missing_columns(fields, remaining_columns, column_strings)
       
        ["\n# Source configuration\n\n",
         "source #{source}\n{",
          SOURCE_SETTINGS._to_conf_string,
          setup_source_database(klass),
          range_select_string(klass),
          build_query(klass, column_strings, join_strings, condition_strings, use_distinct, group_bys),
          "\n" + groups,
          query_info_string(klass, class_id),
          "}\n\n"]
      end
      
      
      def build_query(klass, column_strings, join_strings, condition_strings, use_distinct, group_bys)
        
        primary_key = "#{klass.table_name}.#{klass.primary_key}"
        group_bys = case ADAPTER
          when 'mysql'
            primary_key
          when 'postgresql'
            # Postgres is very fussy about GROUP_BY 
            ([primary_key] + group_bys.reject {|s| s == primary_key}.uniq.sort).join(', ')
          end
        
        ["sql_query =", 
          "SELECT",
          # Avoid DISTINCT; it destroys performance
          column_strings.sort_by do |string| 
            # Sphinx wants them always in the same order, but "id" must be first
            (field = string[/.*AS (.*)/, 1]) == "id" ? "*" : field
          end.join(", "),
          "FROM #{klass.table_name}",
          join_strings.uniq,
          "WHERE #{primary_key} >= $start AND #{primary_key} <= $end",
          condition_strings.uniq.map {|condition| "AND #{condition}" },
          "GROUP BY #{group_bys}"
        ].flatten.compact.join(" ")
      end
      
      
      def add_missing_columns(fields, remaining_columns, column_strings)
        remaining_columns.each do |field|
          column_strings << fields.null(field)
        end
        column_strings
      end
      

      def build_regular_fields(klass, fields, entries, column_strings, join_strings, group_bys, remaining_columns)          
        entries.to_a.each do |entry|
          source_string = "#{entry['table_alias']}.#{entry['field']}"
          group_bys << source_string
          column_strings, remaining_columns = install_field(fields, source_string, entry['as'], entry['function_sql'], entry['facet'], column_strings, remaining_columns)
        end
        
        [column_strings, join_strings, group_bys, remaining_columns]
      end
      

      def build_includes(klass, fields, entries, column_strings, join_strings, group_bys, remaining_columns)                  
        entries.to_a.each do |entry|
          raise ConfigurationError, "You must identify your association with either class_name or association_name, but not both" if entry['class_name'] && entry ['association_name']          
        
          association = get_association(klass, entry)

          # You can use 'class_name' and 'association_sql' to associate to a model that doesn't actually 
          # have an association
          join_klass = association ? association.class_name.constantize : entry['class_name'].constantize
                        
          raise ConfigurationError, "Unknown association from #{klass} to #{entry['class_name'] || entry['association_name']}" if not association and not entry['association_sql']
          
          join_strings = install_join_unless_association_sql(entry['association_sql'], nil, join_strings) do 
            "LEFT OUTER JOIN #{join_klass.table_name} AS #{entry['table_alias']} ON " + 
            if (macro = association.macro) == :belongs_to 
              "#{entry['table_alias']}.#{join_klass.primary_key} = #{klass.table_name}.#{association.primary_key_name}" 
            elsif macro == :has_one
              "#{klass.table_name}.#{klass.primary_key} = #{entry['table_alias']}.#{association.primary_key_name}" 
            else
              raise ConfigurationError, "Unidentified association macro #{macro.inspect}. Please use the :association_sql key to manually specify the JOIN syntax."
            end
          end
          
          source_string = "#{entry['table_alias']}.#{entry['field']}"
          group_bys << source_string
          column_strings, remaining_columns = install_field(fields, source_string, entry['as'], entry['function_sql'], entry['facet'], column_strings, remaining_columns)                         
        end
        
        [column_strings, join_strings, group_bys, remaining_columns]
      end
      
        
      def build_concatenations(klass, fields, entries, column_strings, join_strings, group_bys, use_distinct, remaining_columns)
        entries.to_a.each do |entry|
          if entry['field']
            # Group concats
  
            # Only has_many's or explicit sql right now
            association = get_association(klass, entry)
            
            # You can use 'class_name' and 'association_sql' to associate to a model that doesn't actually 
            # have an association
            join_klass = association ? association.class_name.constantize : entry['class_name'].constantize
        
            join_strings = install_join_unless_association_sql(entry['association_sql'], nil, join_strings) do 
              # XXX make sure foreign key is right for polymorphic relationships
              association = get_association(klass, entry)
              "LEFT OUTER JOIN #{join_klass.table_name} AS #{entry['table_alias']} ON #{klass.table_name}.#{klass.primary_key} = #{entry['table_alias']}.#{association.primary_key_name}" + 
                (entry['conditions'] ? " AND (#{entry['conditions']})" : "")
            end
            
            source_string = "#{entry['table_alias']}.#{entry['field']}"
            # We are using the field in an aggregate, so we don't want to add it to group_bys
            source_string = SQL_FUNCTIONS[ADAPTER]['group_concat']._interpolate(source_string)
            use_distinct = true
            
            column_strings, remaining_columns = install_field(fields, source_string, entry['as'], entry['function_sql'], entry['facet'], column_strings, remaining_columns)
            
          elsif entry['fields']
            # Regular concats
            source_string = "CONCAT_WS(' ', " + entry['fields'].map do |subfield| 
              "#{entry['table_alias']}.#{subfield}"
            end.each do |subsource_string|
              group_bys << subsource_string
            end.join(', ') + ")"
            
            column_strings, remaining_columns = install_field(fields, source_string, entry['as'], entry['function_sql'], entry['facet'], column_strings, remaining_columns)              

          else
            raise ConfigurationError, "Invalid concatenate parameters for #{model}: #{entry.inspect}."
          end
        end
        
        [column_strings, join_strings, group_bys, use_distinct, remaining_columns]
      end
      
    
      def build_index(sources)
        ["\n# Index configuration\n\n",
          "index #{UNIFIED_INDEX_NAME}\n{",
          sources.sort.map do |source| 
            "  source = #{source}"
          end.join("\n"),          
          INDEX_SETTINGS.merge('path' => INDEX_SETTINGS['path'] + "/sphinx_index_#{UNIFIED_INDEX_NAME}")._to_conf_string,
         "}\n\n"]
      end
      
    
      def install_field(fields, source_string, as, function_sql, with_facet, column_strings, remaining_columns)
        source_string = function_sql._interpolate(source_string) if function_sql

        column_strings << fields.cast(source_string, as)
        remaining_columns.delete(as)
        
        # Generate hashed integer fields for text grouping
        if with_facet
          column_strings << "#{SQL_FUNCTIONS[ADAPTER]['hash']._interpolate(source_string)} AS #{as}_facet"
          remaining_columns.delete("#{as}_facet")
        end
        [column_strings, remaining_columns]
      end
      
      
      def install_join_unless_association_sql(association_sql, join_string, join_strings)
        join_strings << (association_sql or join_string or yield)
      end
      
      def say(s)
        Ultrasphinx.say s
      end
      
    end 
  end
end
