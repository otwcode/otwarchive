class SearchController < ApplicationController
  
  before_filter :get_search_results
  
  def get_search_results
    @filters = @tag_categories - [TagCategory.default]
    @tags_by_filter = {}
    @selected_tags = []
    if params[:query]
      @query = params[:query]
      @search = Ultrasphinx::Search.new(:query => params[:query], :sort_mode => 'descending', :sort_by => 'created_at')
      @search.run
      @results = @search.results.paginate(:page => params[:page])
      @filters.each do |filter|
        @tags_by_filter[filter] = Tag.by_category(filter).valid.by_popularity.find(:all, :limit => 50) & @results.collect(&:tags).flatten.uniq
      end
    end		        
  end
  
  def show
  end
  
  def filter
    works_by_category = {}
		for filter in @filters
			unless params[filter.name].blank?
				@selected_tags << params[filter.name]
				query = ''
				params[filter.name].each {|tag_name| query += 'tag:"' + tag_name + '" ' }
				search = Ultrasphinx::Search.new(:query => query)
				search.run  
				works_by_category[filter.id] = search.results.paginate(:page => params[:page])
			end		
		end
		unless works_by_category.blank?
			works_by_category.each_value {|works| @results = @results & works }
			@results = @results.paginate(:page => params[:page])
			@selected_tags.flatten!
		end
		render :action => :show
	end
  
end
