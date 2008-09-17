module ThinkingSphinx
  module ActiveRecord
    # This module contains all the delta-related code for models. There isn't
    # really anything you need to call manually in here - except perhaps
    # index_delta, but not sure what reason why.
    # 
    module Delta
      # Code for after_commit callback is written by Eli Miller:
      # http://elimiller.blogspot.com/2007/06/proper-cache-expiry-with-aftercommit.html
      # with slight modification from Joost Hietbrink.
      #
      def self.included(base)
        base.class_eval do
          # The define_callbacks method was added post Rails 2.0.2 - if it
          # doesn't exist, we define the callback manually
          #
          if respond_to?(:define_callbacks)
            define_callbacks :after_commit
          else
            class << self
              # Handle after_commit callbacks - call all the registered callbacks.
              #
              def after_commit(*callbacks, &block)
                callbacks << block if block_given?
                write_inheritable_array(:after_commit, callbacks)
              end
            end
          end
          
          def after_commit
            # Deliberately blank.
          end
          
          # Normal boolean save wrapped in a handler for the after_commit
          # callback.
          # 
          def save_with_after_commit_callback(*args)
            value = save_without_after_commit_callback(*args)
            callback(:after_commit) if value
            return value
          end
          
          alias_method_chain :save, :after_commit_callback
          
          # Forceful save wrapped in a handler for the after_commit callback.
          #
          def save_with_after_commit_callback!(*args)
            value = save_without_after_commit_callback!(*args)
            callback(:after_commit) if value
            return value
          end
          
          alias_method_chain :save!, :after_commit_callback
          
          # Normal destroy wrapped in a handler for the after_commit callback.
          #
          def destroy_with_after_commit_callback
            value = destroy_without_after_commit_callback
            callback(:after_commit) if value
            return value
          end
          
          alias_method_chain :destroy, :after_commit_callback
          
          private
          
          # Set the delta value for the model to be true.
          def toggle_delta
            self.delta = true
          end
          
          # Build the delta index for the related model. This won't be called
          # if running in the test environment.
          # 
          def index_delta
            return true unless ThinkingSphinx.updates_enabled? &&
              ThinkingSphinx.deltas_enabled?
            
            config = ThinkingSphinx::Configuration.new
            client = Riddle::Client.new config.address, config.port
            
            client.update(
              "#{self.class.indexes.first.name}_core",
              ['sphinx_deleted'],
              {self.id => 1}
            ) if self.in_core_index?
            
            configuration = ThinkingSphinx::Configuration.new
            system "indexer --config #{configuration.config_file} --rotate #{self.class.indexes.first.name}_delta"
            
            true
          end
        end
      end
    end
  end
end
