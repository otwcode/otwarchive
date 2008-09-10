class SearchController < ApplicationController
  
  before_filter :get_search_results
  
  def get_search_results
    @tag_categories = TagCategory.official
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
		if params[:filters]
			params[:filters].each_pair do |category_id, tag_names|
				@selected_tags << tag_names
				search = Ultrasphinx::Search.new(:query => tag_names.join(" "))
        search.run  
				works_by_category[category_id] = search.results.paginate(:page => params[:page])
			end
			works_by_category.each_value {|works| @results = @results & works }
			@results = @results.paginate(:page => params[:page])
			@selected_tags.flatten!
		end
		render :action => :show
	end
  
end
