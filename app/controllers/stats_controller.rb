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
    sort_options = %w[hits date kudos_count comment_thread_count bookmarks_count subscriptions_count word_count].freeze
    @sort = sort_options.include?(params[:sort_column]) ? params[:sort_column] : "hits"
    @dir = params[:sort_direction] == "ASC" ? "ASC" : "DESC"
    params[:sort_column] = @sort
    params[:sort_direction] = @dir

    # Retrieve all year options from chapters
    # TODO: Cache year values?
    @years = ["All Years"] + 
             Chapter.joins(pseuds: :user)
               .where(users: { id: @user.id })
               .where(posted: true)
               .distinct
               .pluck(Arel.sql("YEAR(chapters.published_at)"))
               .sort.map(&:to_s)
    
    @current_year = @years.include?(params[:year]) ? params[:year] : "All Years"

    @stats = stat_items(@user, @sort, @dir, @current_year)
    puts "**** #{@stats}"

    # user_works = Work.joins(pseuds: :user).where(users: { id: @user.id }).where(posted: true)
    # user_chapters = Chapter.joins(pseuds: :user).where(users: { id: @user.id }).where(posted: true)
    # work_query = user_works
    #   .joins(:taggings)
    #   .joins("inner join tags on taggings.tagger_id = tags.id AND tags.type = 'Fandom'")
    #   .select("distinct tags.name as fandom, works.id as id, works.title as title")

    # sort

    # NOTE: Because we are going to be eval'ing the @sort variable later we MUST make sure that its content is
    # checked against the allowlist of valid options
    

    # gather works and sort by specified count
    # @years = ["All Years"] + user_chapters.pluck(:published_at).map { |date| date.year.to_s }
    #   .uniq.sort
    # @current_year = @years.include?(params[:year]) ? params[:year] : "All Years"
    # if @current_year == "All Years"
    #   work_query = work_query.select("works.revised_at as date, works.word_count as word_count")
    # else
    #   next_year = @current_year.to_i + 1
    #   start_date = DateTime.parse("01/01/#{@current_year}")
    #   end_date = DateTime.parse("01/01/#{next_year}")
    #   work_query = work_query
    #     .joins(:chapters)
    #     .where("chapters.posted = 1 AND chapters.published_at >= ? AND chapters.published_at < ?", start_date, end_date)
    #     .select("CONVERT(MAX(chapters.published_at), datetime) as date, SUM(chapters.word_count) as word_count")
    #     .group(:id, :fandom)
    # end
    # works = work_query.all.sort_by { |w| @dir == "ASC" ? (stat_element(w, @sort) || 0) : (0 - (stat_element(w, @sort) || 0).to_i) }

    # on the off-chance a new user decides to look at their stats and have no works
    render "no_stats" and return if @stats.blank?

    @uniq_stats = @stats.uniq

    # group by fandom or flat view
    view_type_opts = %w[fandom flat type]
    @view_type = view_type_opts.include?(params[:view_type]) ? params[:view_type] : "fandom"
    @works = case @view_type
             when "type"
                @uniq_stats.group_by(&:type_label)
             when "flat"
                { ts("All Fandoms") => @uniq_stats }
             else
                puts "SHOULD GET HERE!!!"
                @stats.group_by(&:fandom)
             end

    # gather totals for all works
    # @totals = {}
    # (sort_options - ["date"]).each do |value|
    #   # the inject is used to collect the sum in the "result" variable as we iterate over all the works
    #   @totals[value.split(".")[0].to_sym] = works.uniq.inject(0) { |result, work| result + (stat_element(work, value) || 0) } # sum the works
    # end
    
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
    # chart_col_title = chart_col.split(".")[0].titleize == "Comments" ? ts("Comment Threads") : chart_col.split(".")[0].titleize
    chart_col_title = chart_col.split(".")[0].titleize
    if @sort == "date" && @dir == "ASC"
      chart_title = ts("Oldest")
    elsif @sort == "date" && @dir == "DESC"
      chart_title = ts("Most Recent")
    elsif @dir == "ASC"
      chart_title = ts("Bottom Five Works By #{chart_col_title}")
    else
      chart_title = ts("Top Five Works By #{chart_col_title}")
    end
    @chart_data.new_column("number", chart_col_title)

    # Add Rows and Values
    @chart_data.add_rows(work_items.uniq[0..4].map { |w| [w.title, w.public_send(chart_col)] })

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

  # def stat_element(work, element)
  #   case element.downcase
  #   when "date"
  #     work.date
  #   when "hits"
  #     work.hits
  #   when "kudos.count"
  #     work.kudos.count
  #   when "comment_thread_count"
  #     work.comment_thread_count
  #   when "bookmarks.count"
  #     work.bookmarks.count
  #   when "subscriptions.count"
  #     work.subscriptions.count
  #   when "word_count"
  #     work.word_count
  #   end
  # end
end
