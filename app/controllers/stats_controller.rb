class StatsController < ApplicationController

  before_filter :users_only
  before_filter :load_user
  before_filter :check_ownership

  # only the current user
  def load_user
    @user = current_user
    @check_ownership_of = @user
  end

  # gather statistics for the user on all their works
  def index
    work_query = Work.joins(:pseuds => :user).where("users.id = ?", @user.id).joins(:taggings).
      joins("inner join tags on taggings.tagger_id = tags.id AND tags.type = 'Fandom'").
      select("distinct tags.name as fandom, 
              works.id as id, 
              works.title as title, 
              works.created_at as date,
              works.word_count as word_count")

    # sort 
    sort_options = %w(hits date kudos.count comments.count bookmarks.count subscriptions.count word_count)
    @sort = sort_options.include?(params[:sort_column]) ? params[:sort_column] : "hits"
    @dir = params[:sort_direction] == "ASC" ? "ASC" : "DESC"
    params[:sort_column] = @sort
    params[:sort_direction] = @dir

    works = work_query.all.sort_by {|w| @dir == "ASC" ? (eval("w.#{@sort}") || 0) : (0-(eval("w.#{@sort}") || 0))}    
    
    if params[:flat_view]
      @works = {ts("All Fandoms") => works}
    else
      @works = works.group_by(&:fandom)
    end
    
    @totals = {}
    (sort_options - ["date"]).each do |value|
      @totals[value.split(".")[0].to_sym] = works.inject(0) {|result, work| result + (eval("work.#{value}") || 0)} # sum the works
    end
    @totals[:author_subscriptions] = Subscription.where(:subscribable_id => @user.id, :subscribable_type => 'User').count
    
    # graph top 5 works
    @chart_data = GoogleVisualr::DataTable.new    
    @chart_data.new_column('string', 'Title')
    chart_col = @sort == "date" ? "hits" : @sort 
    chart_col_title = chart_col.split(".")[0].titleize
    chart_title = @sort == "date" ? ts("Most Recent") : ts("Top Five By #{chart_col_title}")
    @chart_data.new_column('number', chart_col_title)
      
    # Add Rows and Values 
    @chart_data.add_rows(works[0..4].map {|w| [w.title, eval("w.#{chart_col}")]})

    # image version of bar chart
    # opts from here: http://code.google.com/apis/chart/image/docs/gallery/bar_charts.html
    @image_chart = GoogleVisualr::Image::BarChart.new(@chart_data, {:isVertical => true}).uri({
     :chtt => chart_title,
     :chs => "800x350",
     :chbh => "a",
     :chxt => "x",
     :chm => "N,000000,0,-1,11"
    })

    @chart = GoogleVisualr::Interactive::ColumnChart.new(@chart_data, :title => chart_title)
    
  end

end
