module ThinkingSphinx
  module HashExcept
    # Returns a new hash without the given keys.
    def except(*keys)
      rejected = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
      reject { |key,| rejected.include?(key) }
    end

    # Replaces the hash without only the given keys.
    def except!(*keys)
      replace(except(*keys))
    end
  end
end

Hash.send(
  :include, ThinkingSphinx::HashExcept
) unless Hash.instance_methods.include?("except")

module ThinkingSphinx
  module ArrayExtractOptions
    def extract_options!
      last.is_a?(::Hash) ? pop : {}
    end
  end
end

Array.send(
  :include, ThinkingSphinx::ArrayExtractOptions
) unless Array.instance_methods.include?("extract_options!")

module ThinkingSphinx
  module MysqlQuotedTableName
    def quote_table_name(name) #:nodoc:
      quote_column_name(name).gsub('.', '`.`')
    end
  end
end

if ActiveRecord::ConnectionAdapters.constants.include?("MysqlAdapter")
  ActiveRecord::ConnectionAdapters::MysqlAdapter.send(
    :include, ThinkingSphinx::MysqlQuotedTableName
  ) unless ActiveRecord::ConnectionAdapters::MysqlAdapter.instance_methods.include?("quote_table_name")
end

module ThinkingSphinx
  module ActiveRecordQuotedName
    def quoted_table_name
      self.connection.quote_table_name(self.table_name)
    end 
  end
end

ActiveRecord::Base.extend(
  ThinkingSphinx::ActiveRecordQuotedName
) unless ActiveRecord::Base.respond_to?("quoted_table_name")