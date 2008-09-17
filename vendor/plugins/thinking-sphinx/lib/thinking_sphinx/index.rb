require 'thinking_sphinx/index/builder'
require 'thinking_sphinx/index/faux_column'

module ThinkingSphinx
  # The Index class is a ruby representation of a Sphinx source (not a Sphinx
  # index - yes, I know it's a little confusing. You'll manage). This is
  # another 'internal' Thinking Sphinx class - if you're using it directly,
  # you either know what you're doing, or messing with things beyond your ken.
  # Enjoy.
  # 
  class Index
    attr_accessor :model, :fields, :attributes, :conditions, :groupings,
      :delta, :options
    
    # Create a new index instance by passing in the model it is tied to, and
    # a block to build it with (optional but recommended). For documentation
    # on the syntax for inside the block, the Builder class is what you want.
    #
    # Quick Example:
    #
    #   Index.new(User) do
    #     indexes login, email
    #     
    #     has created_at
    #     
    #     set_property :delta => true
    #   end
    #
    def initialize(model, &block)
      @model        = model
      @associations = {}
      @fields       = []
      @attributes   = []
      @conditions   = []
      @groupings    = []
      @options      = {}
      @delta        = false
      
      initialize_from_builder(&block) if block_given?
    end
    
    def name
      self.class.name(@model)
    end
    
    def self.name(model)
      model.name.underscore.tr(':/\\', '_')
    end
    
    def empty?(part = :core)
      config = ThinkingSphinx::Configuration.new
      File.size?("#{config.searchd_file_path}/#{self.name}_#{part}.spa").nil?
    end
    
    def to_config(model, index, database_conf, charset_type, offset)
      # Set up associations and joins
      add_internal_attributes
      link!
      
      attr_sources = attributes.collect { |attrib|
        attrib.to_sphinx_clause
      }.join("\n  ")
      
      db_adapter = case adapter
      when :postgres
        "pgsql"
      when :mysql
        "mysql"
      else
        raise "Unsupported Database Adapter: Sphinx only supports MySQL and PosgreSQL"
      end
      
      config = <<-SOURCE

source #{self.class.name(model)}_#{index}_core
{
type     = #{db_adapter}
sql_host = #{database_conf[:host] || "localhost"}
sql_user = #{database_conf[:username] || database_conf[:user]}
sql_pass = #{(database_conf[:password] || "").gsub('#', '\#')}
sql_db   = #{database_conf[:database]}
#{"sql_sock = #{database_conf[:socket]}" unless database_conf[:socket].blank? }

sql_query_pre    = #{charset_type == "utf-8" && adapter == :mysql ? "SET NAMES utf8" : ""}
#{"sql_query_pre    = SET SESSION group_concat_max_len = #{@options[:group_concat_max_len]}" if @options[:group_concat_max_len]}
sql_query_pre    = #{to_sql_query_pre}
sql_query        = #{to_sql(:offset => offset).gsub(/\n/, ' ')}
sql_query_range  = #{to_sql_query_range}
sql_query_info   = #{to_sql_query_info(offset)}
#{attr_sources}
}
      SOURCE
      
      if delta?
        config += <<-SOURCE

source #{self.class.name(model)}_#{index}_delta : #{self.class.name(model)}_#{index}_core
{
sql_query_pre    = 
sql_query_pre    = #{charset_type == "utf-8" && adapter == :mysql ? "SET NAMES utf8" : ""}
#{"sql_query_pre    = SET SESSION group_concat_max_len = #{@options[:group_concat_max_len]}" if @options[:group_concat_max_len]}
sql_query        = #{to_sql(:delta => true, :offset => offset).gsub(/\n/, ' ')}
sql_query_range  = #{to_sql_query_range :delta => true}
}
        SOURCE
      end
      
      config
    end
    
    # Link all the fields and associations to their corresponding
    # associations and joins. This _must_ be called before interrogating
    # the index's fields and associations for anything that may reference
    # their SQL structure.
    # 
    def link!
      base = ::ActiveRecord::Associations::ClassMethods::JoinDependency.new(
        @model, [], nil
      )
      
      @fields.each { |field|
        field.model ||= @model
        field.columns.each { |col|
          field.associations[col] = associations(col.__stack.clone)
          field.associations[col].each { |assoc| assoc.join_to(base) }
        }
      }
      
      @attributes.each { |attribute|
        attribute.model ||= @model
        attribute.columns.each { |col|
          attribute.associations[col] = associations(col.__stack.clone)
          attribute.associations[col].each { |assoc| assoc.join_to(base) }
        }
      }
    end
    
    # Generates the big SQL statement to get the data back for all the fields
    # and attributes, using all the relevant association joins. If you want
    # the version filtered for delta values, send through :delta => true in the
    # options. Won't do much though if the index isn't set up to support a
    # delta sibling.
    # 
    # Examples:
    # 
    #   index.to_sql
    #   index.to_sql(:delta => true)
    #
    def to_sql(options={})
      assocs = all_associations
      
      where_clause = ""
      if self.delta?
        where_clause << " AND #{@model.quoted_table_name}.#{quote_column('delta')}" +" = #{options[:delta] ? db_boolean(true) : db_boolean(false)}"
      end
      unless @conditions.empty?
        where_clause << " AND " << @conditions.join(" AND ")
      end
      
      unique_id_expr = "* #{ThinkingSphinx.indexed_models.size} + #{options[:offset] || 0}"
      
      sql = <<-SQL
SELECT #{ (
  ["#{@model.quoted_table_name}.#{quote_column(@model.primary_key)} #{unique_id_expr} AS #{quote_column(@model.primary_key)} "] + 
  @fields.collect { |field| field.to_select_sql } +
  @attributes.collect { |attribute| attribute.to_select_sql }
).join(", ") }
FROM #{ @model.table_name }
  #{ assocs.collect { |assoc| assoc.to_sql }.join(' ') }
WHERE #{@model.quoted_table_name}.#{quote_column(@model.primary_key)} >= $start
  AND #{@model.quoted_table_name}.#{quote_column(@model.primary_key)} <= $end
  #{ where_clause }
GROUP BY #{ (
  ["#{@model.quoted_table_name}.#{quote_column(@model.primary_key)}"] + 
  @fields.collect { |field| field.to_group_sql }.compact +
  @attributes.collect { |attribute| attribute.to_group_sql }.compact +
  @groupings
).join(", ") }
      SQL
      
      if @model.connection.class.name == "ActiveRecord::ConnectionAdapters::MysqlAdapter"
        sql += " ORDER BY NULL"
      end
      
      sql
    end
    
    # Simple helper method for the query info SQL - which is a statement that
    # returns the single row for a corresponding id.
    # 
    def to_sql_query_info(offset)
      "SELECT * FROM #{@model.quoted_table_name} WHERE " +
      " #{quote_column(@model.primary_key)} = (($id - #{offset}) / #{ThinkingSphinx.indexed_models.size})"
    end
    
    # Simple helper method for the query range SQL - which is a statement that
    # returns minimum and maximum id values. These can be filtered by delta -
    # so pass in :delta => true to get the delta version of the SQL.
    # 
    def to_sql_query_range(options={})
      min_statement = "MIN(#{quote_column(@model.primary_key)})"
      max_statement = "MAX(#{quote_column(@model.primary_key)})"
      
      # Fix to handle Sphinx PostgreSQL bug (it doesn't like NULLs or 0's)
      if adapter == :postgres
        min_statement = "COALESCE(#{min_statement}, 1)"
        max_statement = "COALESCE(#{max_statement}, 1)"
      end
      
      sql = "SELECT #{min_statement}, #{max_statement} " +
            "FROM #{@model.quoted_table_name} "
      sql << "WHERE #{@model.quoted_table_name}.#{quote_column('delta')} " + 
            "= #{options[:delta] ? db_boolean(true) : db_boolean(false)}" if self.delta?
      sql
    end
    
    # Returns the SQL query to run before a full index - ie: nothing unless the
    # index has a delta, and then it's an update statement to set delta values
    # back to 0.
    #
    def to_sql_query_pre
      self.delta? ? "UPDATE #{@model.quoted_table_name} SET #{quote_column('delta')} = #{db_boolean(false)}" : ""
    end
    
    # Flag to indicate whether this index has a corresponding delta index.
    #
    def delta?
      @delta
    end
    
    def adapter
      @adapter ||= case @model.connection.class.name
      when "ActiveRecord::ConnectionAdapters::MysqlAdapter"
        :mysql
      when "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
        :postgres
      else
        raise "Invalid Database Adapter: Sphinx only supports MySQL and PostgreSQL"
      end
    end
    
    def prefix_fields
      @fields.select { |field| field.prefixes }
    end
    
    def infix_fields
      @fields.select { |field| field.infixes }
    end
    
    private
    
    def quote_column(column)
      @model.connection.quote_column_name(column)
    end
    
    # Does all the magic with the block provided to the base #initialize.
    # Creates a new class subclassed from Builder, and evaluates the block
    # on it, then pulls all relevant settings - fields, attributes, conditions,
    # properties - into the new index.
    # 
    # Also creates a CRC attribute for the model.
    # 
    def initialize_from_builder(&block)
      builder = Class.new(Builder)
      builder.setup
      
      builder.instance_eval &block
      
      unless @model.descends_from_active_record?
        stored_class = @model.store_full_sti_class ? @model.name : @model.name.demodulize
        builder.where("#{@model.quoted_table_name}.#{quote_column(@model.inheritance_column)} = '#{stored_class}'")
      end

      @fields     = builder.fields
      @attributes = builder.attributes
      @conditions = builder.conditions
      @groupings  = builder.groupings
      @delta      = builder.properties[:delta]
      @options    = builder.properties.except(:delta)
    end
    
    # Returns all associations used amongst all the fields and attributes.
    # This includes all associations between the model and what the actual
    # columns are from.
    # 
    def all_associations
      @all_associations ||= (
        # field associations
        @fields.collect { |field|
          field.associations.values
        }.flatten +
        # attribute associations
        @attributes.collect { |attrib|
          attrib.associations.values
        }.flatten
      ).uniq.collect { |assoc|
        # get ancestors as well as column-level associations
        assoc.ancestors
      }.flatten.uniq
    end
    
    # Gets a stack of associations for a specific path.
    # 
    def associations(path, parent = nil)
      assocs = []
      
      if parent.nil?
        assocs = association(path.shift)
      else
        assocs = parent.children(path.shift)
      end
      
      until path.empty?
        point = path.shift
        assocs = assocs.collect { |assoc|
          assoc.children(point)
        }.flatten
      end
      
      assocs
    end
    
    # Gets the association stack for a specific key.
    # 
    def association(key)
      @associations[key] ||= Association.children(@model, key)
    end

    # Returns the proper boolean value string literal for the
    # current database adapter.
    #
    def db_boolean(val)
      if adapter == :postgres
        val ? 'TRUE' : 'FALSE'
      else
        val ? '1' : '0'
      end
    end
    
    def crc_column
      if adapter == :postgres
        @model.to_crc32.to_s
      elsif @model.column_names.include?(@model.inheritance_column)
        "IFNULL(CRC32(#{@model.quoted_table_name}.#{quote_column(@model.inheritance_column)}), #{@model.to_crc32.to_s})"
      else
        @model.to_crc32.to_s
      end
    end
    
    def add_internal_attributes
      @attributes << Attribute.new(
        FauxColumn.new(:id),
        :type => :integer,
        :as   => :sphinx_internal_id
      ) unless @attributes.detect { |attr| attr.alias == :sphinx_internal_id }
      
      @attributes << Attribute.new(
        FauxColumn.new(crc_column),
        :type => :integer,
        :as   => :class_crc
      ) unless @attributes.detect { |attr| attr.alias == :class_crc }
      
      @attributes << Attribute.new(
        FauxColumn.new("'" + (@model.send(:subclasses).collect { |klass|
          klass.to_crc32.to_s
        } << @model.to_crc32.to_s).join(",") + "'"),
        :type => :multi,
        :as   => :subclass_crcs
      ) unless @attributes.detect { |attr| attr.alias == :subclass_crcs }
      
      @attributes << Attribute.new(
        FauxColumn.new("0"),
        :type => :integer,
        :as   => :sphinx_deleted
      ) unless @attributes.detect { |attr| attr.alias == :sphinx_deleted }
    end
  end
end
