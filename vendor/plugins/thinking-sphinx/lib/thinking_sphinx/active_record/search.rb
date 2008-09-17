module ThinkingSphinx
  module ActiveRecord
    # This module covers the specific model searches - but the syntax is
    # exactly the same as the core Search class - so use that as your refence
    # point.
    # 
    module Search
      def self.included(base)
        base.class_eval do
          class << self
            # Searches for results that match the parameters provided. Will only
            # return the ids for the matching objects. See
            # ThinkingSphinx::Search#search for syntax examples.
            #
            def search_for_ids(*args)
              options = args.extract_options!
              options[:class] = self
              args << options
              ThinkingSphinx::Search.search_for_ids(*args)
            end

            # Searches for results limited to a single model. See
            # ThinkingSphinx::Search#search for syntax examples.
            #
            def search(*args)
              options = args.extract_options!
              options[:class] = self
              args << options
              ThinkingSphinx::Search.search(*args)
            end

            def search_count(*args)
              options = args.extract_options!
              options[:class] = self
              args << options
              ThinkingSphinx::Search.count(*args)
            end

            def search_for_id(*args)
              options = args.extract_options!
              options[:class] = self
              args << options
              ThinkingSphinx::Search.search_for_id(*args)
            end
          end
        end
      end
    end
  end
end