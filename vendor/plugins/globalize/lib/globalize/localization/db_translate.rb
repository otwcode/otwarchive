module Globalize # :nodoc:

  class WrongLanguageError < ActiveRecord::ActiveRecordError
    attr_reader :original_language, :active_language
    def initialize(orig_lang, active_lang)
      @original_language = orig_lang
      @active_language   = active_lang
    end
  end

  class TranslationTrampleError < ActiveRecord::ActiveRecordError; end

  module DbTranslate  # :nodoc:

    @@keep_translations_in_model = false
    mattr_reader :keep_translations_in_model
    mattr_writer :keep_translations_in_model

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      attr_accessor :keep_translations_in_model

=begin rdoc
      Specifies fields that can be translated. These are normal ActiveRecord
      fields, with corresponding database columns. All the translation
      stuff is done behind the scenes.

      This method takes an array of symbols which are the model attributes
      to be localized.

      === Example:

        #### In your model:

        class Product < ActiveRecord::Base
          translates :name, :description
        end

        #### In environment.rb:

        Locale.set_base_language("en_US")

        #### In your controller:

        Locale.set("en_US")
        product.name -> guitar

        Locale.set("es_ES")
        product.name -> guitarra


      The last entry of the array may be an options hash e.g.

        translates :name, :description, {:some_option => true}

      The available options are described below:

      ==== Option for Bidrectional text (bidi)

      Globalize fully supports Bidirectional text. By default all attributes
      that have been passed to 'translates' will have bidi active.

      If for some reason, you wish do disactivate bidi for a particular attribute
      then you may specify this in the options hash. e.g.

        translates :name, :description, {:name => {:bidi_embed => false}}

      In this example bidi will be active for the 'description' attribute but
      not for the 'name' attribute.

      With 'bidi_embed' active the direction of the string is determined in the
      following manner:

      * If an attribute has no translation for the current locale then the
      direction will be that of the base locale.

      * If an attribute has a translation for the currently active locale then
      the direction of it's value will be that of the active locale.

      Note: This feature is valid for both of the currently supported storage mechanisms


      == Storage Mechanisms

      Globalize now supports two methods of storing model translations:

      * The original globalize mechanism shadows the model's attributes by
        translations in a special translation table

      * A newer alternative approach is to store the translations directly
        within the models own table by duplicating the columns and using
        suffixes to identify the locale.

      Both approaches have their advantages and limitations.

      By default globalize will use the external table to store translations
      so you don't have to do anything special.

      To set the other storage mechanism you have two options.

      1. You can use an application-wide setting which will apply to all
         models by setting the following in your environment.rb:

           Globalize::DbTranslate.keep_translations_in_model = true

      2. The following example shows how you can override this global setting
      for a particular model:

          class Product < ActiveRecord::Base
            self.keep_translations_in_model = true
            translates :name, :description, :specs
          end


      === The External Table Storage Mechanism

      The standard ActiveRecord +find+ method has been tweaked to work with
      Globalize. Use it in the exact same way you would the regular find,
      except for the following provisos:

      1. At this point, it will not work with the <tt>:include</tt> option...
      2. However, there is a replacement: <tt>:include_translated</tt>, which
         is described below.
      3. The <tt>:select</tt> option is prohibited.

      +find+ returns the retreived models, with all translated fields
      correctly loaded, depending on the active language.

      <tt>:include_translated</tt> works as follows:
      any model specified in the <tt>:include_translated</tt> option
      will be eagerly loaded and added to the current model as attributes,
      prefixed with the name of the associated model. This is often referred
      to as _piggybacking_.

      === Example:

        class Product < ActiveRecord::Base
          belongs_to :manufacturer
          belongs_to :category
        end

        class Category < ActiveRecord::Base
          has_many :products
          translates :name
        end

        prods = Product.find(:all, :include_translated => [ :manufacturer, :category ])
        prods.first.category_name -> "batedeira"


      With this option, for every locale change you need to reload your
      model instance.


      === The Same Table As Model Storage Mechanism

      Your model's fields, with their corresponding database columns, need
      to have a duplicate column that is named with the locale language code
      as a suffix.

      i.e. Apart from the original field's column there should be a column
      for each locale that is to be supported.

      === Example:

       #### In your model (assuming Globalize::DbTranslate.keep_translations_in_model is true):

       class Product < ActiveRecord::Base
         translates :name, :description
       end

       #### In your schema:

       (Assuming english is the base locale, and we want to support spanish)

       create_table :products do |t|
         t.column :id, :integer
         t.column :name, :string
         t.column :name_es, :string
         t.column :description, :string
         t.column :description_es, :string
         ...

       end

      ==== Advantages

      * This method avoids any extra joins (and thus the limitations to
        ActiveRecord::Base#find that apply when using the default mechanism)

      * This also means that you have all the localized versions of
        your model instance's data in one query.

      * Changing locale doesn't necesitate a reload of the model object in
        order to access the localized data for the new locale.

      ==== Disadvantages

      * Having to maintain all those extra columns may prove to be a
        maintenance problem but by using ActiveRecord migrations this
        should be painless.


      === Example usage:

        Locale.set_base_language('en-US')
        Locale.set('en-US')

        #writes to 'name', 'description' columns
        product = Product.create(:name => 'boots', :description => 'shiny red wellies')

        puts product.name #Accesses name column (english)
        > 'boots'

        Locale.set('es-ES')
        product.name = 'botas'
        product.save
        puts product.name #Accesses name_es column (spanish),
        > 'botas'

        puts product._name #Accesses original 'name' column
        > 'boots'

        Locale.set('en-US')
        puts product.name #Accesses name column (english)
        > 'boots'

      You can create any 'find' query you want without limitation.

      A further feature of this mechanism is that the ActiveRecord dynamic
      attribute finder mechanism has been overriden to automatically use the
      right field for the active locale:

        Locale.set('es-ES')
        product = Product.find_by_name('botas')
        puts product.name
        > 'botas'

        Locale.set('en-US')
        product = Product.find_by_name('boots')
        puts product.name
        > 'boots'

        Locale.set('es-ES')
        puts product.name
        > 'botas'

      Use #{facet}_is_base? to check if a translation exists.

        Locale.set('en-US')
        product = Product.create(:name => 'shoes')

        Locale.set('es-ES')
        product.name_is_base?
        > true

        product.name = 'zapatos'
        product.save
        product.name_is_base?
        > false

      Use MyModel.localized_facet(facet) class method to return the correct localized
      column name of the current locale. Useful for custom ActiveRecord find queries.

      e.g.

        Product.find(:all , :conditions = ["#{Product.localized_facet(:name)} = ?", name])


      <b>Note</b>: The column name suffix that should be used to name the localized columns
      (in example Spanish) is that returned by:

        Locale.new('es-ES').language.code (For this example)


      ==== Further Options
      When using this mechanism the following option is available:

        :base_as_default

        e.g.
          class Product
            translates :name, :base_as_default => true
          end

      Set to true (default is false), when you switch to a non-base locale, localized attributes
      will return the base locale's value rather than nil if no translation exists
      for that attribute.

        e.g.

          product = Product.new

          Locale.set("en_US")
          product.name = guitar

          Locale.set("es_ES")

          #With :base_as_default => true
          product.name #=> guitar

          #With :base_as_default => false
          product.name #=> nil

        Then:

          product.name = guitarra

          Locale.set("en_US")
          product.name #=> guitar

          Locale.set("es_ES")
          product.name #=> guitarra

=end
      def translates(*facets)
        # parse out options hash
        options = facets.pop if facets.last.kind_of? Hash
        options ||= {}
        options.reverse_merge!({:base_as_default => false})

        keep_translations_internally = true
        if self.keep_translations_in_model.nil?
          keep_translations_internally = ::Globalize::DbTranslate.keep_translations_in_model
        else
          keep_translations_internally = self.keep_translations_in_model
        end

        keep_translations_internally ? translate_internal(facets, options) : translate_external(facets, options)
      end

=begin rdoc
      Optionally specifies translated fields to be preloaded on <tt>find</tt>. For instance,
      in a product catalog, you may want to do a <tt>find</tt> of the first 10 products:

        Product.find(:all, :limit => 10, :order => "name")

      But you wouldn't want to load the complete descriptions and specs of all the
      products, just the names and summaries. So you'd specify:

        class Product < ActiveRecord::Base
          translates :name, :summary, :description, :specs
          translates_preload :name, :summary
          ...
        end

      By default (if no translates_preload is specified), Globalize will preload
      the first field given to <tt>translates</tt>. It will also fully load on
      a <tt>find(:first)</tt> or when <tt>:translate_all => true</tt> is given as a find option.

      # Note: <i>Use when Globalize::DbTranslate.keep_translations_in_model is false</i>
=end
      def translates_preload(*facets)
        module_eval <<-HERE
          @@preload_facets = facets
        HERE
      end

      protected

        #Alternative storage mechanism storing the translations in the models
        #own tables.
        #
        #<i>i.e. Globalize::DbTranslate.keep_translations_in_model is true</i>
        def translate_internal(facets, options)
          facets_string = "[" + facets.map {|facet| ":#{facet}"}.join(", ") + "]"
          class_eval %{
            @@facet_options = {}
            @@globalize_facets = #{facets_string}

            class << self

              def globalize_facets
                @@globalize_facets
              end


              #Returns the localized column name of the supplied attribute for the
              #current locale
              #
              #Useful when you have to build up sql by hand or for AR::Base::find conditions
              #
              #  e.g. Product.find(:all , :conditions = ["\#{Product.localized_facet(:name)} = ?", name])
              #
              # Note: <i>Used when Globalize::DbTranslate.keep_translations_in_model is true</i>
              def localized_facet(facet)
                unless Locale.base?
                  "\#{facet}_\#{Locale.language.code}"
                else
                  facet.to_s
                end
              end

              alias_method :globalize_old_method_missing, :method_missing unless
                respond_to? :globalize_old_method_missing
            end

            def globalize_facets_hash
              @@globalize_facets_hash ||= globalize_facets.inject({}) {|hash, facet|
                hash[facet.to_s] = true; hash
              }
            end

            def non_localized_fields
              @@non_localized_fields ||=
                column_names.map {|cn| cn.intern } - globalize_facets
            end

            #Is field translated?
            #Returns true if translated
            #Warning! Depends on Locale.switch_locale
            def translated?(facet, locale_code = nil)
              localized_method = "\#{facet}_\#{Locale.language.code}"

              Locale.switch_locale(locale_code) do
                localized_method = "\#{facet}_\#{Locale.language.code}"
              end if locale_code

              value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
              return !value.nil?
            end

            extend  Globalize::DbTranslate::InternalStorageClassMethods
          }

          facets.each do |facet|
            bidi = (!(options[facet] && !options[facet][:bidi_embed])).to_s
            class_eval %{

              #Handle facet-specific options (.e.g a bidirectional setting)
              @@facet_options[:#{facet}] ||= {}
              @@facet_options[:#{facet}][:bidi] = #{bidi}

              #Accessor that proxies to the right accessor for the current locale
              def #{facet}
                value = nil
                unless Locale.base?
                  localized_method = "#{facet}_\#{Locale.language.code}"
                  value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
                  value = value ? value : read_attribute(:#{facet}) if #{options[:base_as_default]}
                else
                  value = read_attribute(:#{facet})
                end
                value.nil? ? nil : add_bidi(value, :#{facet})
              end

              #Accessor before typecasting that proxies to the right accessor for the current locale
              def #{facet}_before_type_cast
                unless Locale.base?
                  localized_method = "#{facet}_\#{Locale.language.code}_before_type_cast"
                  value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
                  value = value ? value : read_attribute_before_type_cast('#{facet}') if #{options[:base_as_default]}
                  return value
                else
                  value = read_attribute_before_type_cast('#{facet}')
                end
                value.nil? ? nil : add_bidi(value, :#{facet})
              end

              #Write to appropriate localized attribute
              def #{facet}=(value)
                unless Locale.base?
                  localized_method = "#{facet}_\#{Locale.language.code}"
                  write_attribute(localized_method.to_sym, value) if respond_to?(localized_method.to_sym)
                else
                  write_attribute(:#{facet}, value)
                end
              end

              #Is field translated?
              #Returns true if untranslated
              def #{facet}_is_base?
                localized_method = "#{facet}_\#{Locale.language.code}"
                value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
                return value.nil?
              end

              #Read base language attribute directly
              def _#{facet}
                value = read_attribute(:#{facet})
                value.nil? ? nil : add_bidi(value, :#{facet})
              end

              #Read base language attribute directly without typecasting
              def _#{facet}_before_type_cast
                read_attribute_before_type_cast('#{facet}')
              end

              #Write base language attribute directly
              def _#{facet}=(value)
                write_attribute(:#{facet}, value)
              end

              def add_bidi(value, facet)
                return value unless Locale.active?
                value.direction = self.send("\#{facet}_is_base?") ?
                  (Locale.base_language ? Locale.base_language.direction : nil) :
                  (Locale.active ? Locale.language.direction : nil)

                  # insert bidi embedding characters, if necessary
                  if @@facet_options[facet][:bidi] &&
                      Locale.language && Locale.language.direction && value.direction
                    if Locale.language.direction == 'ltr' && value.direction == 'rtl'
                      bidi_str = "\xe2\x80\xab" + value + "\xe2\x80\xac"
                      bidi_str.direction = value.direction
                      return bidi_str
                    elsif Locale.language.direction == 'rtl' && value.direction == 'ltr'
                      bidi_str = "\xe2\x80\xaa" + value + "\xe2\x80\xac"
                      bidi_str.direction = value.direction
                      return bidi_str
                    end
                  end
                  return value
              end

              protected :add_bidi
            }
          end
        end

        #Default Globalize translations storage mechanism
        #<i>i.e. Globalize::DbTranslate.keep_translations_in_model is false</i>
        def translate_external(facets, options)
          facets_string = "[" + facets.map {|facet| ":#{facet}"}.join(", ") + "]"
          class_eval <<-HERE
            @@facet_options = {}
            attr_writer :fully_loaded
            def fully_loaded?; @fully_loaded; end
            @@globalize_facets = #{facets_string}
            @@preload_facets ||= @@globalize_facets
            class << self

              def sqlite?; defined?(ActiveRecord::ConnectionAdapters::SQLiteAdapter) and connection.kind_of?(ActiveRecord::ConnectionAdapters::SQLiteAdapter); end

              def globalize_facets
                @@globalize_facets
              end

              def globalize_facets_hash
                @@globalize_facets_hash ||= globalize_facets.inject({}) {|hash, facet|
                  hash[facet.to_s] = true; hash
                }
              end

              def untranslated_fields
                @@untranslated_fields ||=
                  column_names.map {|cn| cn.intern } - globalize_facets
              end

              def preload_facets; @@preload_facets; end
              def postload_facets
                @@postload_facets ||= @@globalize_facets - @@preload_facets
              end
              alias_method :globalize_old_find_every, :find_every unless
                respond_to? :globalize_old_find_every
            end
            alias_method :globalize_old_reload,   :reload
            alias_method :globalize_old_destroy,  :destroy
            alias_method :globalize_old_create_or_update, :create_or_update
            alias_method :globalize_old_update, :update

            include Globalize::DbTranslate::TranslateObjectMethods
            extend  Globalize::DbTranslate::TranslateClassMethods

          HERE

          facets.each do |facet|
            bidi = (!(options[facet] && !options[facet][:bidi_embed])).to_s
            class_eval <<-HERE
              @@facet_options[:#{facet}] ||= {}
              @@facet_options[:#{facet}][:bidi] = #{bidi}

              def #{facet}
                if not_original_language
                  raise WrongLanguageError.new(@original_language, Locale.language)
                end
                load_other_translations if
                  !fully_loaded? && !self.class.preload_facets.include?(:#{facet})
                result = read_attribute(:#{facet})
                return nil if result.nil?
                result.direction = #{facet}_is_base? ?
                  (Locale.base_language ? Locale.base_language.direction : nil) :
                  (@original_language ? @original_language.direction : nil)

                # insert bidi embedding characters, if necessary
                if @@facet_options[:#{facet}][:bidi] &&
                    Locale.language && Locale.language.direction && result.direction
                  if Locale.language.direction == 'ltr' && result.direction == 'rtl'
                    bidi_str = "\xe2\x80\xab" + result + "\xe2\x80\xac"
                    bidi_str.direction = result.direction
                    return bidi_str
                  elsif Locale.language.direction == 'rtl' && result.direction == 'ltr'
                    bidi_str = "\xe2\x80\xaa" + result + "\xe2\x80\xac"
                    bidi_str.direction = result.direction
                    return bidi_str
                  end
                end

                return result
              end

              def #{facet}=(arg)
                raise WrongLanguageError.new(@original_language, Locale.language) if
                  not_original_language
                write_attribute(:#{facet}, arg)
              end

              def #{facet}_is_base?
                self['#{facet}_not_base'].nil?
              end
            HERE
          end
        end
    end

    module TranslateObjectMethods # :nodoc: all

      module_eval <<-HERE
      def not_original_language
        return false if @original_language.nil?
        return @original_language != Locale.language
      end

      def set_original_language
        @original_language = Locale.language
      end
      HERE

      def load_other_translations
        postload_facets = self.class.postload_facets
        return if postload_facets.empty? || new_record?

        table_name = self.class.table_name
        facet_selection = postload_facets.join(", ")
        base = connection.select_one("SELECT #{facet_selection} " +
          " FROM #{table_name} WHERE #{self.class.primary_key} = #{id}",
          "loading base for load_other_translations")
        base.each {|key, val| write_attribute( key, val ) }

        unless Locale.base?
          trs = ModelTranslation.find(:all,
            :conditions => [ "table_name = ? AND item_id = ? AND language_id = ? AND " +
            "facet IN (#{[ '?' ] * postload_facets.size * ', '})", table_name,
            self.id, Locale.active.language.id ] + postload_facets.map {|facet| facet.to_s} )
          trs ||= []
          trs.each do |tr|
            attr = tr.text || base[tr.facet.to_s]
            write_attribute( tr.facet, attr )
          end
        end
        self.fully_loaded = true
      end

      def destroy
        globalize_old_destroy
        ModelTranslation.delete_all( [ "table_name = ? AND item_id = ?",
          self.class.table_name, id ])
      end

      def reload
        globalize_old_reload
        set_original_language
      end

      private

        # Returns copy of the attributes hash where all the values have been safely quoted for use in
        # an SQL statement.
        # REDEFINED to include only untranslated fields. We don't want to overwrite the
        # base translation with other translations.
        def attributes_with_quotes(include_primary_key = true, include_readonly_attributes = true)
          if Locale.base?
            quoted = attributes.inject({}) do |quoted, (name, value)|
              if column = column_for_attribute(name)
                quoted[name] = quote_value(value, column) unless !include_primary_key && column.primary
              end
              quoted
            end
          else
            quoted = attributes.inject({}) do |quoted, (name, value)|
              if !self.class.globalize_facets_hash.has_key?(name) &&
                  column = column_for_attribute(name)
                quoted[name] = quote_value(value, column) unless !include_primary_key && column.primary
              end
              quoted
            end
          end
	        include_readonly_attributes ? quoted : remove_readonly_attributes(quoted)
        end

        def create_or_update
          result = globalize_old_create_or_update
          update_translation if Locale.active && result
          result
        end

        def update
          status = true
          status = globalize_old_update unless attributes_with_quotes(false).empty?
          status
        end

        def update_translation
          raise WrongLanguageError.new(@original_language, Locale.language) if
            not_original_language

          set_original_language

          # nothing to do, facets updated in main model
          return if Locale.base?

          table_name = self.class.table_name
          self.class.globalize_facets.each do |facet|
            next unless has_attribute?(facet)
            text = read_attribute(facet)
            language_id = Locale.active.language.id
            tr = ModelTranslation.find(:first, :conditions =>
              [ "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
              table_name, id, facet.to_s, language_id ])
            if tr.nil?
              # create new record
              ModelTranslation.create(:table_name => table_name,
                :item_id => id, :facet => facet.to_s,
                :language_id => language_id,
                :text => text) unless text.nil?
            elsif text.blank?
              # delete record
              tr.destroy
            else
              # update record
              tr.update_attribute(:text, text) if tr.text != text
            end
          end # end facets loop
        end

    end

    module TranslateClassMethods

      # Use this instead of +find+ if you want to bypass the translation
      # code for any reason.
      #
      # Note: <i>Use when Globalize::DbTranslate.keep_translations_in_model is false</i>
      def untranslated_find(*args)
        has_options = args.last.is_a?(Hash)
        options = has_options ? args.last : {}
        options[:untranslated] = true
        args << options if !has_options
        find(*args)
      end

      protected
        # FIX: figure out how to use default rails VALID_FIND_OPTIONS constant
        VALID_FIND_OPTIONS = [ :conditions, :include, :joins, :limit, :offset,
                               :order, :select, :readonly, :group, :from,
                               :untranslated, :include_translated ]

        def validate_find_options(options) #:nodoc:
          options.assert_valid_keys(VALID_FIND_OPTIONS)
        end

      private
        def find_every(options)
          return globalize_old_find_every(options) if options[:untranslated]

          # do quick version if base language is active
          if Locale.base? && !options.has_key?(:include_translated)
            results = globalize_old_find_every(options)
            results.each {|result|
              result.set_original_language
            }
            return results
          end

          options[:conditions] = sanitize_sql(options[:conditions]) if options[:conditions]

          joins_clause = options[:joins].nil? ? "" : options[:joins].dup
          joins_args = []
          load_full = options[:translate_all]
          facets = load_full ? globalize_facets : preload_facets

          if options[:select].nil? || options[:select] = '*'
            surrounding_clause = '%s'
          else
            surrounding_clause = options[:select]
            re_select = Regexp.new("#{table_name}.*")
            if surrounding_clause =~ re_select
              surrounding_clause = surrounding_clause.gsub(re_select, '%s')
            else
              raise StandardError,
              "this :select option format is not allowed on translatable models " +
              "(#{options[:select]})"
            end
          end

          # there will at least be an +id+ field here
          select_clause = untranslated_fields.map {|f| "#{table_name}.#{f}" }.join(", ")

          if Locale.base?
            select_clause <<  ', ' << facets.map {|f| "#{table_name}.#{f}" }.join(", ")
          else
            language_id = Locale.active.language.id
            load_full = options[:translate_all]
            facets = load_full ? globalize_facets : preload_facets

=begin
          There's a bug in sqlite that messes up sorting when aliasing fields,
          see: <http://www.sqlite.org/cvstrac/tktview?tn=1521,33>.

          Since I want to use sqlite, and sorting, I'm hacking this to make it work.
          This involves renaming order by fields and adding them to the SELECT part.
          It's a sucky hack, but hopefully sqlite will fix the bug soon.
=end

            # sqlite bug hack
            select_position = untranslated_fields.size

            # initialize where tweaking
            if options[:conditions].nil?
              where_clause = ""
            else
              if options[:conditions].kind_of? Array
                conditions_is_array = true
                where_clause = options[:conditions].shift
              else
                where_clause = options[:conditions]
              end
            end

            facets.each do |facet|
              facet = facet.to_s
              facet_table_alias = "t_#{facet}"

              # sqlite bug hack
              select_position += 1
              options[:order].sub!(/\b#{facet}\b/, select_position.to_s) if options[:order] && sqlite?

              select_clause << ", COALESCE(#{facet_table_alias}.text, #{table_name}.#{facet}) AS #{facet}, "
              select_clause << " #{facet_table_alias}.text AS #{facet}_not_base "
              joins_clause  << " LEFT OUTER JOIN globalize_translations AS #{facet_table_alias} " +
                "ON #{facet_table_alias}.table_name = ? " +
                "AND #{table_name}.#{primary_key} = #{facet_table_alias}.item_id " +
                "AND #{facet_table_alias}.facet = ? AND #{facet_table_alias}.language_id = ? "
              joins_args << table_name << facet << language_id

              #for translated fields inside WHERE clause substitute corresponding COALESCE string
              where_clause.gsub!(/((((#{table_name}\.)|\W)#{facet})|^#{facet})\W/, " COALESCE(#{facet_table_alias}.text, #{table_name}.#{facet}) ")
            end

            options[:conditions] = sanitize_sql(
              conditions_is_array ? [ where_clause ] + options[:conditions] : where_clause
            ) unless options[:conditions].nil?
          end

          # add in associations (of :belongs_to nature) if applicable
          associations = options[:include_translated] || []
          associations = [ associations ].flatten
          associations.each do |assoc|
            rfxn = reflect_on_association(assoc)
            assoc_type = rfxn.macro
            raise StandardError,
              ":include_translated associations must be of type :belongs_to;" +
              "#{assoc} is #{assoc_type}" if assoc_type != :belongs_to
            klass = rfxn.klass
            assoc_facets = klass.preload_facets
            included_table = klass.table_name
            included_fk = klass.primary_key
            fk = rfxn.options[:foreign_key] || "#{assoc}_id"
            assoc_facets.each do |facet|
              facet_table_alias = "t_#{assoc}_#{facet}"

             if Locale.base?
                select_clause << ", #{included_table}.#{facet} AS #{assoc}_#{facet} "
              else
                select_clause << ", COALESCE(#{facet_table_alias}.text, #{included_table}.#{facet}) " +
                  "AS #{assoc}_#{facet} "
                joins_clause << " LEFT OUTER JOIN globalize_translations AS #{facet_table_alias} " +
                  "ON #{facet_table_alias}.table_name = ? " +
                  "AND #{table_name}.#{fk} = #{facet_table_alias}.item_id " +
                  "AND #{facet_table_alias}.facet = ? AND #{facet_table_alias}.language_id = ? "
                joins_args << klass.table_name << facet.to_s << language_id
              end
            end
            joins_clause << "LEFT OUTER JOIN #{included_table} " +
                "ON #{table_name}.#{fk} = #{included_table}.#{included_fk} "
          end

          options[:select] = surrounding_clause % select_clause
          options[:readonly] = false

          sanitized_joins_clause = sanitize_sql( [ joins_clause, *joins_args ] )
          options[:joins] = sanitized_joins_clause
          results = globalize_old_find_every(options)

          results.each {|result|
            result.set_original_language
            result.fully_loaded = true if load_full
          }

          return results
        end
    end

    module InternalStorageClassMethods

      private

      # Overridden to ensure that dynamic finders using localized attributes
      # like find_by_user_name(user_name) or find_by_user_name_and_password(user_name, password)
      # use the appropriately localized column.
      #
      # Note: <i>Used when Globalize::DbTranslate.keep_translations_in_model is true</i>
      def method_missing(method_id, *arguments)
        if match = /find_(all_by|by)_([_a-zA-Z]\w*)/.match(method_id.to_s)
          finder = determine_finder(match)

          facets = extract_attribute_names_from_match(match)
          super unless all_attributes_exists?(facets)

          #Overrride facets to use appropriate attribute name for current locale
          facets.collect! {|attr_name| respond_to?(:globalize_facets) && globalize_facets.include?(attr_name.intern) ? localized_facet(attr_name) : attr_name}

          attributes = construct_attributes_from_arguments(facets, arguments)

          case extra_options = arguments[facets.size]
            when nil
              options = { :conditions => attributes }
              set_readonly_option!(options)
              ActiveSupport::Deprecation.silence { send(finder, options) }

            when Hash
              finder_options = extra_options.merge(:conditions => attributes)
              validate_find_options(finder_options)
              set_readonly_option!(finder_options)

              if extra_options[:conditions]
                with_scope(:find => { :conditions => extra_options[:conditions] }) do
                  ActiveSupport::Deprecation.silence { send(finder, finder_options) }
                end
              else
                ActiveSupport::Deprecation.silence { send(finder, finder_options) }
              end

            else
              raise ArgumentError, "Unrecognized arguments for #{method_id}: #{extra_options.inspect}"
          end
        elsif match = /find_or_(initialize|create)_by_([_a-zA-Z]\w*)/.match(method_id.to_s)
          instantiator = determine_instantiator(match)
          facets = extract_attribute_names_from_match(match)
          super unless all_attributes_exists?(facets)

          if arguments[0].is_a?(Hash)
            attributes = arguments[0].with_indifferent_access
            find_attributes = attributes.slice(*facets)
          else
            find_attributes = attributes = construct_attributes_from_arguments(facets, arguments)
          end
          options = { :conditions => find_attributes }
          set_readonly_option!(options)

          find_initial(options) || send(instantiator, attributes)
        else
          super
        end
      end
    end
  end
end
