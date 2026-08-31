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
    @page_subtitle = t(".page_title", username: @user.login)
    user_works = Work.joins(pseuds: :user).where(users: { id: @user.id }).where(posted: true)
    user_chapters = Chapter.joins(pseuds: :user).where(users: { id: @user.id }).where(posted: true)
    user_series = Series.joins(pseuds: :user).where(users: { id: @user.id })
    work_query = user_works
      .joins(:taggings)
      .joins("inner join tags on taggings.tagger_id = tags.id AND tags.type = 'Fandom'")
      .select("distinct tags.name as fandom, works.id as id, works.title as title, 'Work' as type_label")
    series_query = user_series
      .joins(work_tags: :taggings)
      .joins("inner join tags on taggings.tagger_id = tags.id AND tags.type = 'Fandom'")
      .select("distinct tags.name as fandom, series.id as id, series.title as title, 'Series' as type_label")

    # sort

    # NOTE: Because we are going to be eval'ing the @sort variable later we MUST make sure that its content is
    # checked against the allowlist of valid options
    sort_options = %w[hits date kudos.count comment_thread_count bookmarks.count subscriptions.count word_count]
    @sort = sort_options.include?(params[:sort_column]) ? params[:sort_column] : "hits"

    @dir = params[:sort_direction] == "ASC" ? "ASC" : "DESC"
    params[:sort_column] = @sort
    params[:sort_direction] = @dir

    # gather works and series and sort by specified count
    @years = ["All Years"] + user_chapters.pluck(:published_at).map { |date| date.year.to_s }
      .uniq.sort
    @current_year = @years.include?(params[:year]) ? params[:year] : "All Years"
    if @current_year == "All Years"
      work_query = work_query.select("works.revised_at as date, works.word_count as word_count")
      series_query = series_query.select("series.updated_at as date")
    else
      next_year = @current_year.to_i + 1
      start_date = DateTime.parse("01/01/#{@current_year}")
      end_date = DateTime.parse("01/01/#{next_year}")
      work_query = work_query
        .joins(:chapters)
        .where("chapters.posted = 1 AND chapters.published_at >= ? AND chapters.published_at < ?", start_date, end_date)
        .select("CONVERT(MAX(chapters.published_at), datetime) as date, SUM(chapters.word_count) as word_count")
        .group(:id, :fandom)
      series_query = series_query
        .where("series.updated_at >= ? AND series.updated_at < ?", start_date, end_date)
        .group(:id, :fandom)
    end
    
    works = work_query.all.to_a
    series = series_query.all.to_a

    works_and_series = works.concat(series).sort_by { |w| @dir == "ASC" ? (stat_element(w, @sort) || 0) : (0 - (stat_element(w, @sort) || 0).to_i) }

    # on the off-chance a new user decides to look at their stats and have no works
    render "no_stats" and return if works_and_series.blank?

    # group by fandom or flat view or type view
    view_type_opts = %w[fandom flat type].freeze
    @view_type = view_type_opts.include?(params[:view_type]) ? params[:view_type] : "fandom"
    @works_and_series = case @view_type
                        when "type"
                          works_and_series.uniq.group_by(&:type_label)
                        when "flat"
                          { ts("All Fandoms") => works_and_series.uniq }
                        else
                          works_and_series.group_by(&:fandom)
                        end
                    
    # gather totals for all works and series
    works_uniq = works.uniq
    series_uniq = series.uniq
    @totals = {
      kudos: sum_field(works_uniq, "kudos.count"),
      comment_thread_count: sum_field(works_uniq, "comment_thread_count"),
      work_bookmarks: sum_field(works_uniq, "bookmarks.count"),
      work_subscriptions: sum_field(works_uniq, "subscriptions.count"),
      series_bookmarks: sum_field(series_uniq, "bookmarks.count"),
      series_subscriptions: sum_field(series_uniq, "subscriptions.count"),
      word_count: sum_field(works_uniq, "word_count"),
      hits: sum_field(works_uniq, "hits")
    }
    @totals[:user_subscriptions] = Subscription.where(subscribable_id: @user.id, subscribable_type: "User").count

    # graph top 5 works
    @chart_data = GoogleVisualr::DataTable.new
    @chart_data.new_column("string", "Title")

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
    @chart_data.new_column("number", chart_col_title)

    # Add Rows and Values
    @chart_data.add_rows(works_and_series.uniq[0..4].map { |w| [w.title, stat_element(w, chart_col)] })

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
      # Series don't have hits
      work.type_label == "Work" ? work.hits : 0
    when "kudos.count"
      # Series don't have kudos
      work.type_label == "Work" ? work.kudos.count : 0
    when "comment_thread_count"
      # Series don't have comment thread count
      work.type_label == "Work" ? work.comment_thread_count : 0
    when "bookmarks.count"
      work.bookmarks.count
    when "subscriptions.count"
      work.subscriptions.count
    when "word_count"
      work.type_label == "Work" ? work.word_count : work.public_word_count
    end
  end

  def sum_field(items, field)
    items.sum { |i| stat_element(i, field) || 0 }
  end
end
