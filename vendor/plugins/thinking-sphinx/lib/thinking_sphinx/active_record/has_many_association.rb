module ThinkingSphinx
  module ActiveRecord
    module HasManyAssociation
      def search(*args)
        foreign_key = @reflection.primary_key_name
        stack = [@reflection.options[:through]].compact
        
        attribute   = nil
        (@reflection.klass.indexes || []).each do |index|
          attribute = index.attributes.detect { |attrib|
            attrib.columns.length == 1 &&
            attrib.columns.first.__name  == foreign_key.to_sym &&
            attrib.columns.first.__stack == stack
          }
          break if attribute
        end
        
        raise "Missing Attribute for Foreign Key #{foreign_key}" unless attribute
        
        options = args.extract_options!
        options[:with] ||= {}
        options[:with][attribute.unique_name] = @owner.id
        
        args << options
        @reflection.klass.search(*args)
      end
    end
  end
end