module ThinkingSphinx
  class Index
    # The Builder class is the core for the index definition block processing.
    # There are four methods you really need to pay attention to:
    # - indexes (aliased to includes and attribute)
    # - has (aliased to attribute)
    # - where
    # - set_property (aliased to set_properties)
    #
    # The first two of these methods allow you to define what data makes up
    # your indexes. #where provides a method to add manual SQL conditions, and
    # set_property allows you to set some settings on a per-index basis. Check
    # out each method's documentation for better ideas of usage.
    # 
    class Builder
      class << self
        # No idea where this is coming from - haven't found it in any ruby or
        # rails documentation. It's not needed though, so it gets undef'd.
        # Hopefully the list of methods that get in the way doesn't get too
        # long.
        undef_method :parent
        
        attr_accessor :fields, :attributes, :properties, :conditions,
          :groupings
        
        # Set up all the collections. Consider this the equivalent of an
        # instance's initialize method.
        # 
        def setup
          @fields     = []
          @attributes = []
          @properties = {}
          @conditions = []
          @groupings  = []
        end
        
        # This is how you add fields - the strings Sphinx looks at - to your
        # index. Technically, to use this method, you need to pass in some
        # columns and options - but there's some neat method_missing stuff
        # happening, so lets stick to the expected syntax within a define_index
        # block.
        #
        # Expected options are :as, which points to a column alias in symbol
        # form, and :sortable, which indicates whether you want to sort by this
        # field.
        #
        # Adding Single-Column Fields:
        # 
        # You can use symbols or methods - and can chain methods together to
        # get access down the associations tree.
        # 
        #   indexes :id, :as => :my_id
        #   indexes :name, :sortable => true
        #   indexes first_name, last_name, :sortable => true
        #   indexes users.posts.content, :as => :post_content
        #   indexes users(:id), :as => :user_ids
        #
        # Keep in mind that if any keywords for Ruby methods - such as id or 
        # name - clash with your column names, you need to use the symbol
        # version (see the first, second and last examples above).
        #
        # If you specify multiple columns (example #2), a field will be created
        # for each. Don't use the :as option in this case. If you want to merge
        # those columns together, continue reading.
        # 
        # Adding Multi-Column Fields:
        # 
        #   indexes [first_name, last_name], :as => :name
        #   indexes [location, parent.location], :as => :location
        #
        # To combine multiple columns into a single field, you need to wrap
        # them in an Array, as shown by the above examples. There's no
        # limitations on whether they're symbols or methods or what level of
        # associations they come from.
        # 
        # Adding SQL Fragment Fields
        #
        # You can also define a field using an SQL fragment, useful for when
        # you would like to index a calculated value.
        #
        #   indexes "age < 18", :as => :minor
        #
        def indexes(*args)
          options = args.extract_options!
          args.each do |columns|
            fields << Field.new(FauxColumn.coerce(columns), options)
            
            if fields.last.sortable
              attributes << Attribute.new(
                fields.last.columns.collect { |col| col.clone },
                options.merge(
                  :type => :string,
                  :as => fields.last.unique_name.to_s.concat("_sort").to_sym
                )
              )
            end
          end
        end
        alias_method :field,    :indexes
        alias_method :includes, :indexes
        
        # This is the method to add attributes to your index (hence why it is
        # aliased as 'attribute'). The syntax is the same as #indexes, so use
        # that as starting point, but keep in mind the following points.
        # 
        # An attribute can have an alias (the :as option), but it is always
        # sortable - so you don't need to explicitly request that. You _can_
        # specify the data type of the attribute (the :type option), but the
        # code's pretty good at figuring that out itself from peering into the
        # database.
        # 
        # Attributes are limited to the following types: integers, floats,
        # datetimes (converted to timestamps), booleans and strings. Don't
        # forget that Sphinx converts string attributes to integers, which are
        # useful for sorting, but that's about it.
        # 
        # You can also have a collection of integers for multi-value attributes
        # (MVAs). Generally these would be through a has_many relationship,
        # like in this example:
        # 
        #   has posts(:id), :as => :post_ids
        # 
        # This allows you to filter on any of the values tied to a specific
        # record. Might be best to read through the Sphinx documentation to get
        # a better idea of that though.
        # 
        # Adding SQL Fragment Attributes
        #
        # You can also define an attribute using an SQL fragment, useful for
        # when you would like to index a calculated value. Don't forget to set
        # the type of the attribute though:
        #
        #   indexes "age < 18", :as => :minor, :type => :boolean
        # 
        # If you're creating attributes for latitude and longitude, don't
        # forget that Sphinx expects these values to be in radians.
        # 
        def has(*args)
          options = args.extract_options!
          args.each do |columns|
            attributes << Attribute.new(FauxColumn.coerce(columns), options)
          end
        end
        alias_method :attribute, :has
        
        # Use this method to add some manual SQL conditions for your index
        # request. You can pass in as many strings as you like, they'll get
        # joined together with ANDs later on.
        # 
        #   where "user_id = 10"
        #   where "parent_type = 'Article'", "created_at < NOW()"
        # 
        def where(*args)
          @conditions += args
        end
        
        # Use this method to add some manual SQL strings to the GROUP BY
        # clause. You can pass in as many strings as you'd like, they'll get
        # joined together with commas later on.
        # 
        #   group_by "lat", "lng"
        # 
        def group_by(*args)
          @groupings += args
        end
        
        # This is what to use to set properties on the index. Chief amongst
        # those is the delta property - to allow automatic updates to your
        # indexes as new models are added and edited - but also you can
        # define search-related properties which will be the defaults for all
        # searches on the model.
        # 
        #   set_property :delta => true
        #   set_property :field_weights => {"name" => 100}
        # 
        # Also, the following two properties are particularly relevant for
        # geo-location searching - latitude_attr and longitude_attr. If your
        # attributes for these two values are named something other than
        # lat/latitude or lon/long/longitude, you can dictate what they are
        # when defining the index, so you don't need to specify them for every
        # geo-related search.
        #
        #   set_property :latitude_attr => "lt", :longitude => "lg"
        # 
        # Please don't forget to add a boolean field named 'delta' to your
        # model's database table if enabling the delta index for it.
        # 
        def set_property(*args)
          options = args.extract_options!
          if options.empty?
            @properties[args[0]] = args[1]
          else
            @properties.merge!(options)
          end
        end
        alias_method :set_properties, :set_property
        
        # Handles the generation of new columns for the field and attribute
        # definitions.
        # 
        def method_missing(method, *args)
          FauxColumn.new(method, *args)
        end
      end
    end
  end
end
