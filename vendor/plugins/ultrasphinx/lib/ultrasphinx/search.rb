
module Ultrasphinx

=begin rdoc
Command-interface Search object.

== Basic usage
  
To set up a search, instantiate an Ultrasphinx::Search object with a hash of parameters. Only the <tt>:query</tt> key is mandatory.
  @search = Ultrasphinx::Search.new(
    :query => @query, 
    :sort_mode => 'descending', 
    :sort_by => 'created_at'
  )
    
Now, to run the query, call its <tt>run</tt> method. Your results will be available as ActiveRecord instances via the <tt>results</tt> method. Example:  
  @search.run
  @search.results

= Options

== Query format

The query string supports boolean operation, parentheses, phrases, and field-specific search. Query words are stemmed and joined by an implicit <tt>AND</tt> by default.

* Valid boolean operators are <tt>AND</tt>, <tt>OR</tt>, and <tt>NOT</tt>.
* Field-specific searches should be formatted as <tt>fieldname:contents</tt>. (This will only work for text fields. For numeric and date fields, see the <tt>:filters</tt> parameter, below.)
* Phrases must be enclosed in double quotes.
    
A Sphinx::SphinxInternalError will be raised on invalid queries. In general, queries can only be nested to one level. 
  @query = 'dog OR cat OR "white tigers" NOT (lions OR bears) AND title:animals'

== Hash parameters

The hash lets you customize internal aspects of the search.

<tt>:per_page</tt>:: An integer. How many results per page.
<tt>:page</tt>:: An integer. Which page of the results to return.
<tt>:class_names</tt>:: An array or string. The class name of the model you want to search, an array of model names to search, or <tt>nil</tt> for all available models.    
<tt>:sort_mode</tt>:: <tt>'relevance'</tt> or <tt>'ascending'</tt> or <tt>'descending'</tt>. How to order the result set. Note that <tt>'time'</tt> and <tt>'extended'</tt> modes are available, but not tested.  
<tt>:sort_by</tt>:: A field name. What field to order by for <tt>'ascending'</tt> or <tt>'descending'</tt> mode. Has no effect for <tt>'relevance'</tt>.
<tt>:weights</tt>:: A hash. Text-field names and associated query weighting. The default weight for every field is 1.0. Example: <tt>:weights => {'title' => 2.0}</tt>
<tt>:filters</tt>:: A hash. Names of numeric or date fields and associated values. You can use a single value, an array of values, or a range. (See the bottom of the ActiveRecord::Base page for an example.)
<tt>:facets</tt>:: An array of fields for grouping/faceting. You can access the returned facet values and their result counts with the <tt>facets</tt> method.

Note that you can set up your own query defaults in <tt>environment.rb</tt>: 
  
  self.class.query_defaults = HashWithIndifferentAccess.new({
    :per_page => 10,
    :sort_mode => 'relevance',
    :weights => {'title' => 2.0}
  })

= Advanced features

== Interlock integration
  
Ultrasphinx uses the <tt>find_all_by_id</tt> method to instantiate records. If you set <tt>with_finders: true</tt> in {Interlock's}[http://blog.evanweaver.com/files/doc/fauna/interlock] <tt>config/memcached.yml</tt>, Interlock overrides <tt>find_all_by_id</tt> with a caching version.

== Will_paginate integration

The Search instance responds to the same methods as a WillPaginate::Collection object, so once you have called <tt>run</tt> or <tt>excerpt</tt> you can use it directly in your views:

  will_paginate(@search)

== Excerpt mode

You can have Sphinx excerpt and highlight the matched sections in the associated fields. Instead of calling <tt>run</tt>, call <tt>excerpt</tt>. 
  
  @search.excerpt

The returned models will be frozen and have their field contents temporarily changed to the excerpted and highlighted results. 
  
You need to set the <tt>content_methods</tt> key on Ultrasphinx::Search.excerpting_options to whatever groups of methods you need the excerpter to try to excerpt. The first responding method in each group for each record will be excerpted. This way Ruby-only methods are supported (for example, a metadata method which combines various model fields, or an aliased field so that the original record contents are still available).
  
There are some other keys you can set, such as excerpt size, HTML tags to highlight with, and number of words on either side of each excerpt chunk. Example (in <tt>environment.rb</tt>):
  
  Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
    :before_match => '<strong>', 
    :after_match => '</strong>',
    :chunk_separator => "...",
    :limit => 256,
    :around => 3,
    :content_methods => [['title'], ['body', 'description', 'content'], ['metadata']] 
  })
  
Note that your database is never changed by anything Ultrasphinx does.

=end    

  class Search  
  
    include Internals
    include Parser
    
    cattr_accessor :query_defaults  
    self.query_defaults ||= HashWithIndifferentAccess.new({
      :query => nil,
      :page => 1,
      :per_page => 20,
      :sort_by => nil,
      :sort_mode => 'relevance',
      :weights => {},
      :class_names => [],
      :filters => {},
      :facets => []
    })
    
    cattr_accessor :excerpting_options
    self.excerpting_options ||= HashWithIndifferentAccess.new({
      :before_match => "<strong>", :after_match => "</strong>",
      :chunk_separator => "...",
      :limit => 256,
      :around => 3,
      # Results should respond to one in each group of these, in precedence order, for the excerpting to fire
      :content_methods => [['title', 'name'], ['body', 'description', 'content'], ['metadata']] 
    })
    
    cattr_accessor :client_options
    self.client_options ||= HashWithIndifferentAccess.new({ 
      :with_subtotals => false, 
      :ignore_missing_records => false,
      # Has no effect if :ignore_missing_records => false
      :max_missing_records => 5, 
      :max_retries => 4,
      :retry_sleep_time => 0.5,
      :max_facets => 100,
      :with_global_rank => false,
      # Finder methods must accept an Array of ids, but do not have to preserve order
      :finder_methods => ['find_all_by_id'] 
    })
    
    # Friendly sort mode mappings    
    SPHINX_CLIENT_PARAMS = { 
      'sort_mode' => {
        'relevance' => :relevance,
        'descending' => :attr_desc, 
        'ascending' => :attr_asc, 
        'time' => :time_segments,
        'extended' => :extended,
      }
    }
    
    INTERNAL_KEYS = ['parsed_query'] #:nodoc:

    def self.get_models_to_class_ids #:nodoc:
      # Reading the conf file makes sure that we are in sync with the actual Sphinx index,
      # not whatever you happened to change your models to most recently
      unless File.exist? CONF_PATH
        Ultrasphinx.say "configuration file not found for #{RAILS_ENV.inspect} environment"
        Ultrasphinx.say "please run 'rake ultrasphinx:configure'"
      else
        begin  
          lines = open(CONF_PATH).readlines          

          sources = lines.select do |line| 
            line =~ /^source \w/
          end.map do |line| 
            line[/source ([\w\d_-]*)/, 1].gsub('__', '/').classify
          end
          
          ids = lines.select do |line| 
            line =~ /^sql_query /
          end.map do |line| 
            line[/(\d*) AS class_id/, 1].to_i
          end
          
          raise unless sources.size == ids.size          
          Hash[*sources.zip(ids).flatten]
                                  
        rescue
          Ultrasphinx.say "#{CONF_PATH} file is corrupted"
          Ultrasphinx.say "please run 'rake ultrasphinx:configure'"
        end    
        
      end
    end

    MODELS_TO_IDS = get_models_to_class_ids || {} 

    IDS_TO_MODELS = MODELS_TO_IDS.invert #:nodoc:
      
    MAX_MATCHES = DAEMON_SETTINGS["max_matches"].to_i 
    
    FACET_CACHE = {} #:nodoc: 
    
    # Returns the options hash.
    def options
      @options
    end
    
    #  Returns the query string used.
    def query
      # Redundant with method_missing
      @options['query']
    end
    
    def parsed_query #:nodoc:
      # Redundant with method_missing
      @options['parsed_query']
    end
    
    # Returns an array of result objects.
    def results
      require_run
      @results
    end
    
    # Returns the facet map for this query, if facets were used.
    def facets
      raise UsageError, "No facet field was configured" unless @options['facets']
      require_run
      @facets
    end      
          
    # Returns the raw response from the Sphinx client.
    def response
      require_run
      @response
    end
    
    # Returns a hash of total result counts, scoped to each available model. This requires extra queries against the search daemon right now. Set <tt>Ultrasphinx::Search.client_options[:with_subtotals] = true</tt> to enable the extra queries. Most of the overhead is in instantiating the AR result sets, so the performance hit is not usually significant.
    def subtotals
      raise UsageError, "Subtotals are not enabled" unless self.class.client_options['with_subtotals']
      require_run
      @subtotals
    end

    # Returns the total result count.
    def total_entries
      require_run
      [response[:total_found] || 0, MAX_MATCHES].min
    end  
  
    # Returns the response time of the query, in milliseconds.
    def time
      require_run
      response[:time]
    end

    # Returns whether the query has been run.  
    def run?
      !@response.blank?
    end
 
    # Returns the current page number of the result set. (Page indexes begin at 1.) 
    def current_page
      @options['page']
    end
  
    # Returns the number of records per page.
    def per_page
      @options['per_page']
    end
        
    # Returns the last available page number in the result set.  
    def page_count
      require_run    
      (total_entries / per_page.to_f).ceil
    end
            
    # Returns the previous page number.
    def previous_page 
      current_page > 1 ? (current_page - 1) : nil
    end

    # Returns the next page number.
    def next_page
      current_page < page_count ? (current_page + 1) : nil
    end
    
    # Returns the global index position of the first result on this page.
    def offset 
      (current_page - 1) * per_page
    end
    
    # Builds a new command-interface Search object.
    def initialize opts = {} 

      # Change to normal hashes with String keys for speed
      opts = Hash[HashWithIndifferentAccess.new(opts._deep_dup._coerce_basic_types)]
      unless self.class.query_defaults.instance_of? Hash
        self.class.query_defaults = Hash[self.class.query_defaults]
        self.class.client_options = Hash[self.class.client_options]
        self.class.excerpting_options = Hash[self.class.excerpting_options]
        self.class.excerpting_options['content_methods'].map! {|ary| ary.map {|m| m.to_s}}
      end    
      
      @options = self.class.query_defaults.merge(opts)            
      @options['query'] = @options['query'].to_s
      @options['class_names'] = Array(@options['class_names'])
      @options['facets'] = Array(@options['facets'])
            
      raise UsageError, "Weights must be a Hash" unless @options['weights'].is_a? Hash
      raise UsageError, "Filters must be a Hash" unless @options['filters'].is_a? Hash
      
      @options['parsed_query'] = parse(query)
  
      @results, @subtotals, @facets, @response = [], {}, {}, {}
        
      extra_keys = @options.keys - (self.class.query_defaults.keys + INTERNAL_KEYS)
      say "discarded invalid keys: #{extra_keys * ', '}" if extra_keys.any? and RAILS_ENV != "test" 
    end
    
    # Run the search, filling results with an array of ActiveRecord objects. Set the parameter to false if you only want the ids returned.
    def run(reify = true)
      @request = build_request_with_options(@options)

      say "searching for #{@options.inspect}"

      perform_action_with_retries do
        @response = @request.query(parsed_query, UNIFIED_INDEX_NAME)
        say "search returned #{total_entries}/#{response[:total_found].to_i} in #{time.to_f} seconds."
          
        if self.class.client_options['with_subtotals']        
          @subtotals = get_subtotals(@request, parsed_query) 
        end
        
        Array(@options['facets']).each do |facet|
          @facets[facet] = get_facets(@request, parsed_query, facet)
        end        
        
        @results = convert_sphinx_ids(response[:matches])
        @results = reify_results(@results) if reify
        
        say "warning; #{response[:warning]}" if response[:warning]
        raise UsageError, response[:error] if response[:error]
        
      end      
      self
    end
  
  
    # Overwrite the configured content attributes with excerpted and highlighted versions of themselves.
    # Runs run if it hasn't already been done.
    def excerpt
    
      require_run         
      return if results.empty?
    
      # See what fields in each result might respond to our excerptable methods
      results_with_content_methods = results.map do |result|
        [result, 
          self.class.excerpting_options['content_methods'].map do |methods|
            methods.detect do |this| 
              result.respond_to? this
            end
          end
        ]
      end
  
      # Fetch the actual field contents
      docs = results_with_content_methods.map do |result, methods|
        methods.map do |method| 
          method and strip_bogus_characters(result.send(method)) or ""
        end
      end.flatten
      
      excerpting_options = {
        :docs => docs, 
        :index => UNIFIED_INDEX_NAME, 
        :words => strip_query_commands(parsed_query)
      }
      self.class.excerpting_options.except('content_methods').each do |key, value|
        # Riddle only wants symbols
        excerpting_options[key.to_sym] ||= value
      end
      
      responses = perform_action_with_retries do 
        # Ship to Sphinx to highlight and excerpt
        @request.excerpts(excerpting_options)
      end
      
      responses = responses.in_groups_of(self.class.excerpting_options['content_methods'].size)
      
      results_with_content_methods.each_with_index do |result_and_methods, i|
        # Override the individual model accessors with the excerpted data
        result, methods = result_and_methods
        methods.each_with_index do |method, j|
          data = responses[i][j]
          if method
            result._metaclass.send('define_method', method) { data }
            attributes = result.instance_variable_get('@attributes')
            attributes[method] = data if attributes[method]
          end
        end
      end
  
      @results = results_with_content_methods.map do |result_and_content_method| 
        result_and_content_method.first.freeze
      end
      
      self
    end  
    
            
    # Delegates enumerable methods to @results, if possible. This allows us to behave directly like a WillPaginate::Collection. Failing that, we delegate to the options hash if a key is set. This lets us use <tt>self</tt> directly in view helpers.
    def method_missing(*args, &block)
      if @results.respond_to? args.first
        @results.send(*args, &block)
      elsif options.has_key? args.first.to_s
        @options[args.first.to_s]
      else
        super
      end
    end
  
    def say msg #:nodoc:
      Ultrasphinx.say msg
    end
    
    private
    
    def require_run
      run unless run?
    end
    
  end
end
