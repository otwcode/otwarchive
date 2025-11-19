class StatsController < ApplicationController
  include StatsHelper

  before_action :users_only
  before_action :load_user
  before_action :check_ownership

  # only the current user
  def load_user
    @user = current_user
    @check_ownership_of = @user
  end

  # gather statistics for the user on all their works
  def index
    # Retrieve all year options from chapters
    @years = ["All Years"] + 
             Chapter.joins(pseuds: :user)
               .where(users: { id: @user.id })
               .where(posted: true)
               .distinct
               .pluck(Arel.sql("YEAR(chapters.published_at)"))
               .sort.map(&:to_s)
    
    @current_year = @years.include?(params[:year]) ? params[:year] : "All Years"

    @sort, @dir = sanitize_sort_params(params[:sort_column], params[:sort_direction])
    params[:sort_column] = @sort
    params[:sort_direction] = @dir

    @stats = stat_items(@user, @sort, @dir, @current_year)

    # on the off-chance a new user decides to look at their stats and have no works
    render "no_stats" and return if @stats.blank?

    @uniq_stats = @stats.uniq

    # group by fandom or flat view
    view_type_opts = %w[fandom flat type].freeze
    @view_type = view_type_opts.include?(params[:view_type]) ? params[:view_type] : "fandom"
    @works = case @view_type
             when "type"
               @uniq_stats.group_by(&:type_label)
             when "flat"
               { t(".all_fandoms") => @uniq_stats }
             else
               @stats.group_by(&:fandom)
             end

    # gather totals for all works and series
    work_items = @uniq_stats.select { |item| item.type == "WORK" }
    series_items = @uniq_stats.select { |item| item.type == "SERIES" }
    @totals = {
      kudos: sum_field(work_items, :kudos_count),
      work_bookmarks: sum_field(work_items, :bookmarks_count),
      series_bookmarks: sum_field(series_items, :bookmarks_count),
      work_subscriptions: sum_field(work_items, :subscriptions_count),
      series_subscriptions: sum_field(series_items, :subscriptions_count),
      word_count: sum_field(work_items, :word_count),
      comment_thread_count: sum_field(work_items, :comment_thread_count),
      hits: sum_field(work_items, :hits)
    }
    @totals[:user_subscriptions] = Subscription.where(subscribable_id: @user.id, subscribable_type: "User").count

    # graph top 5 works
    @chart_data = GoogleVisualr::DataTable.new
    @chart_data.new_column("string", "Title")

    chart_col = @sort == "date" ? "hits" : @sort
    chart_col_title = chart_col.titleize

    chart_title = if @sort == "date"
                    @dir == "ASC" ? t(".most_recent") : t(".oldest")
                  else
                    @dir == "ASC" ? t(".bottom_five", chart_col_title: chart_col_title) : t(".top_five", chart_col_title: chart_col_title)
                  end
    @chart_data.new_column("number", chart_col_title)

    # Add Rows and Values
    @chart_data.add_rows(work_items.uniq[0..4].map { |w| [w.title, stat_element(w, chart_col)] })

    # image version of bar chart
    # opts from here: http://code.google.com/apis/chart/image/docs/gallery/bar_charts.html
    @image_chart = GoogleVisualr::Image::BarChart.new(@chart_data, { isVertical: true }).uri(
      {
        chtt: chart_title,
        chs: "800x350",
        chbh: "a",
        chxt: "x",
        chm: "N,000000,0,-1,11"
      }
    )

    options = {
      colors: ["#993333"],
      title: chart_title,
      vAxis: {
        viewWindow: { min: 0 }
      }
    }
    @chart = GoogleVisualr::Interactive::ColumnChart.new(@chart_data, options)
  end

  private

  def sum_field(items, field)
    items.sum { |i| i.public_send(field).to_i }
  end
end
