class StatsController < ApplicationController

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
    user_works = Work.joins(pseuds: :user).where(users: { id: @user.id }).where(posted: true)
    user_chapters = Chapter.joins(pseuds: :user).where(users: { id: @user.id }).where(posted: true)
    work_query = user_works
      .joins(:taggings)
      .joins("inner join tags on taggings.tagger_id = tags.id AND tags.type = 'Fandom'")
      .select("distinct tags.name as fandom, works.id as id, works.title as title")

    # sort

    # NOTE: Because we are going to be eval'ing the @sort variable later we MUST make sure that its content is
    # checked against the allowlist of valid options
    sort_options = %w[hits date kudos.count comment_thread_count bookmarks.count subscriptions.count word_count]
    @sort = sort_options.include?(params[:sort_column]) ? params[:sort_column] : "hits"

    @dir = params[:sort_direction] == "ASC" ? "ASC" : "DESC"
    params[:sort_column] = @sort
    params[:sort_direction] = @dir

    # gather works and sort by specified count
    @years = ["All Years"] + user_chapters.pluck(:published_at).map { |date| date.year.to_s }
      .uniq.sort
    @current_year = @years.include?(params[:year]) ? params[:year] : "All Years"
    if @current_year == "All Years"
      work_query = work_query.select("works.revised_at as date, works.word_count as word_count")
    else
      next_year = @current_year.to_i + 1
      start_date = DateTime.parse("01/01/#{@current_year}")
      end_date = DateTime.parse("01/01/#{next_year}")
      work_query = work_query
        .joins(:chapters)
        .where("chapters.posted = 1 AND chapters.published_at >= ? AND chapters.published_at < ?", start_date, end_date)
        .select("convert(MAX(chapters.published_at), datetime) as date, SUM(chapters.word_count) as word_count")
        .group(:id)
    end
    works = work_query.all.sort_by { |w| @dir == "ASC" ? (stat_element(w, @sort) || 0) : (0 - (stat_element(w, @sort) || 0).to_i) }

    # on the off-chance a new user decides to look at their stats and have no works
    render "no_stats" and return if works.blank?

    # group by fandom or flat view
    if params[:flat_view]
      @works = {ts("All Fandoms") => works.uniq}
    else
      @works = works.group_by(&:fandom)
    end

    # gather totals for all works
    @totals = {}
    (sort_options - ["date"]).each do |value|
      # the inject is used to collect the sum in the "result" variable as we iterate over all the works
      @totals[value.split(".")[0].to_sym] = works.uniq.inject(0) { |result, work| result + (stat_element(work, value) || 0) } # sum the works
    end
    @totals[:user_subscriptions] = Subscription.where(subscribable_id: @user.id, subscribable_type: 'User').count

    # graph top 5 works
    @chart_data = GoogleVisualr::DataTable.new
    @chart_data.new_column('string', 'Title')

    chart_col = @sort == "date" ? "hits" : @sort
    chart_col_title = chart_col.split(".")[0].titleize == "Comments" ? ts("Comment Threads") : chart_col.split(".")[0].titleize
    if @sort == "date" && @dir == "ASC"
      chart_title = ts("Oldest")
    elsif @sort == "date" && @dir == "DESC"
      chart_title = ts("Most Recent")
    elsif @dir == "ASC"
      chart_title = ts("Bottom Five By #{chart_col_title}")
    else
      chart_title = ts("Top Five By #{chart_col_title}")
    end
    @chart_data.new_column('number', chart_col_title)

    # Add Rows and Values
    @chart_data.add_rows(works.uniq[0..4].map { |w| [w.title, stat_element(w, chart_col)] })

    # image version of bar chart
    # opts from here: http://code.google.com/apis/chart/image/docs/gallery/bar_charts.html
    @image_chart = GoogleVisualr::Image::BarChart.new(@chart_data, {isVertical: true}).uri({
     chtt: chart_title,
     chs: "800x350",
     chbh: "a",
     chxt: "x",
     chm: "N,000000,0,-1,11"
    })

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

  def stat_element(work, element)
    case element.downcase
    when "date"
      work.date
    when "hits"
      work.hits
    when "kudos.count"
      work.kudos.count
    when "comment_thread_count"
      work.comment_thread_count
    when "bookmarks.count"
      work.bookmarks.count
    when "subscriptions.count"
      work.subscriptions.count
    when "word_count"
      work.word_count
    end
  end
end
