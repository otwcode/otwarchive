
module Ultrasphinx

=begin rdoc
This is a special singleton configuration class that stores the index field configurations. Rather than using a magic hash and including relevant behavior in Ultrasphinx::Configure and Ultrasphinx::Search, we unify it here.
=end

  class Fields
    include Singleton
    include Associations
    
    TYPE_MAP = {
      'string' => 'text', 
      'text' => 'text', 
      'integer' => 'integer', 
      'date' => 'date', 
      'datetime' => 'date',
      'timestamp' => 'date',
      'float' => 'float',
      'boolean' => 'bool'
    }
        
    attr_accessor :classes, :types
    
    def initialize
      @types = {}
      @classes = Hash.new([])
      @groups = []
    end
    
    def groups
      @groups.compact.sort_by do |string| 
        string[/= (.*)/, 1]
      end
    end
  
    def save_and_verify_type(field, new_type, string_sortable, klass)
      # Smoosh fields together based on their name in the Sphinx query schema
      field, new_type = field.to_s, TYPE_MAP[new_type.to_s]

      if types[field]
        # Existing field name; verify its type
        raise ConfigurationError, "Column type mismatch for #{field.inspect}; was already #{types[field].inspect}, but is now #{new_type.inspect}." unless types[field] == new_type
        classes[field] = (classes[field] + [klass]).uniq

      else
        # New field      
        types[field] = new_type
        classes[field] = [klass]

        @groups << case new_type
          when 'integer'
            "sql_attr_uint = #{field}"
          when 'float'
            "sql_attr_float = #{field}"
          when 'bool'
            "sql_attr_bool = #{field}"
          when 'date'
            "sql_attr_timestamp = #{field}"
          when 'text' 
            "sql_attr_str2ordinal = #{field}" if string_sortable
        end
      end
    end
    
    def cast(source_string, field)
      if types[field] == "date"
        "UNIX_TIMESTAMP(#{source_string})"
      elsif types[field] == "integer"
        source_string # "CAST(#{source_string} AS UNSIGNED)"
      else
        source_string              
      end + " AS #{field}"
    end    
      
    def null(field)      
      case types[field]
        when 'text'
          "''"
        when 'integer', 'float', 'bool'
          "0"
        when 'date'
          "18000" # Midnight on 1/1/1970
        when nil
          raise "Field #{field} is missing"
        else
          raise "Field #{field} does not have a valid type #{types[field]}."
      end + " AS #{field}"
    end
    
    def configure(configuration)

      configuration.each do |model, options|        

        klass = model.constantize        
        save_and_verify_type('class_id', 'integer', nil, klass)
        save_and_verify_type('class', 'string', nil, klass)
                
        begin
        
          # Fields are from the model
          # We destructively canonicize them back onto the configuration hash
          options['fields'] = options['fields'].to_a.map do |entry|
            entry = {'field' => entry} unless entry.is_a? Hash

            extract_table_alias!(entry, klass)
            extract_field_alias!(entry, klass)
            
            unless klass.columns_hash[entry['field']]
              # XXX I think this is here for migrations
              Ultrasphinx.say "warning: field #{entry['field']} is not present in #{model}"
            else
              save_and_verify_type(entry['as'], klass.columns_hash[entry['field']].type, entry['sortable'], klass)
              install_facets!(entry, klass)
            end            
          end  
          
          # Joins are whatever they are in the target       
          options['include'].to_a.each do |entry|
            extract_table_alias!(entry, klass)
            extract_field_alias!(entry, klass)
            
            association_model = get_association_model(klass, entry)
            
            save_and_verify_type(entry['as'] || entry['field'], association_model.columns_hash[entry['field']].type, entry['sortable'], klass)
            install_facets!(entry, klass)
          end  
          
          # Regular concats are CHAR, group_concats are BLOB and need to be cast to CHAR
          options['concatenate'].to_a.each do |entry|
            extract_table_alias!(entry, klass)
            save_and_verify_type(entry['as'], 'text', entry['sortable'], klass) 
            install_facets!(entry, klass)
          end          
          
        rescue ActiveRecord::StatementInvalid
          Ultrasphinx.say "warning: model #{model} does not exist in the database yet"
        end  
      end
      
      self
    end
    
    def install_facets!(entry, klass)
      if entry['facet']
        save_and_verify_type(entry['as'], 'text', nil, klass) # source must be a string
        save_and_verify_type("#{entry['as']}_facet", 'integer', nil, klass)
      end
      entry
    end
    
    def extract_field_alias!(entry, klass)
      unless entry['as']    
        entry['as'] = entry['field'] 
      end
    end
    
    def extract_table_alias!(entry, klass)
      unless entry['table_alias']
        entry['table_alias'] = if entry['field'] and entry['field'].include? "." and entry['association_sql']
          # This field is referenced by a table alias in association_sql
          table_alias, entry['field'] = entry['field'].split(".")
          table_alias
        elsif get_association(klass, entry)
          # Refers to the association
          get_association(klass, entry).name
        elsif entry['association_sql']
          # Refers to the association_sql class's table
          entry['class_name'].constantize.table_name
        else
          # Refers to this class
          klass.table_name
        end
      end
    end
    
  end
end
    
