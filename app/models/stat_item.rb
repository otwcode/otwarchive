class StatItem
  include Rails.application.routes.url_helpers

  attr_reader :type, :id, :title, :fandom, :fandom_string, :hits,
              :word_count, :date,
              :bookmarks_count, :subscriptions_count,
              :kudos_count, :comment_thread_count, :work_count

  def initialize(record)
    @type = record["type"]
    @id = record["id"]
    @title = record["title"]
    @fandom = record["fandom"]
    @fandom_string = record["fandom_string"]
    @hits = record["hits"]
    @word_count = record["word_count"]&.to_i || 0
    @date = record["date"]
    @bookmarks_count = record["bookmarks_count"]&.to_i || 0
    @subscriptions_count = record["subscriptions_count"]&.to_i || 0
    @kudos_count = record["kudos_count"]&.to_i || 0
    @comment_thread_count = record["comment_thread_count"]&.to_i || 0
    @work_count = record["work_count"]&.to_i || 0
  end

  def work?
    type == "WORK"
  end

  def series?
    type == "SERIES"
  end

  def item_path
    series? ? series_path(id: @id) : work_path(id: @id)
  end

  def type_label
    case type
    when "WORK" then "Works"
    when "SERIES" then "Series"
    else type.titleize
    end
  end

  # Uniqueness
  def ==(other)
    other.is_a?(StatItem) && id == other.id && type == other.type
  end

  alias eql? ==

  def hash
    [type, id].hash
  end
end
