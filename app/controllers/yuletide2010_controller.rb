class Yuletide2010Controller < ApplicationController

  layout 'yuletide2010'

  before_filter :load_yuletide
  before_filter :require_login, :only => [:restricted_works, :restricted_work]

  caches_page :index,
              :show,
              :work,
              :fandoms,
              :anime_fandoms,
              :book_fandoms,
              :comic_fandoms,
              :movie_fandoms,
              :music_fandoms,
              :other_fandoms,
              :rpf_fandoms,
              :theater_fandoms,
              :tv_fandoms,
              :video_game_fandoms,
              :madness

  caches_action :restricted_works, :restricted_work


  def index
    @media = Media.canonical - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
  end

  def show
    @fandom = Fandom.find_by_name(params[:id])
    @works = Work.with_all_filters([@fandom]).
              in_collection(@collection).
              visible_to_all.
              order(:title)
  end

  def work
    @work = Work.find(params[:id])
    @chapters = @work.chapters.posted
  end

  def restricted_works
    @works = Work.in_collection(@collection).where(:restricted => true).order(:title)
  end

  def restricted_work
    @work = Work.find(params[:id])
    @chapters = @work.chapters.posted
    render :work
  end
                                                                                
  def fandoms
    fandoms_for_media
  end

  def anime_fandoms
    @medium = Media.find_by_name("Anime & Manga")
    fandoms_for_media
  end

  def book_fandoms
    @medium = Media.find_by_name("Books & Literature")
    fandoms_for_media
  end

  def comic_fandoms
    @medium = Media.find_by_name("Cartoons & Comics & Graphic Novels")
    fandoms_for_media
  end

  def movie_fandoms
    @medium = Media.find_by_name("Movies")
    fandoms_for_media
  end

  def music_fandoms
    @medium = Media.find_by_name("Music & Bands")
    fandoms_for_media
  end

  def other_fandoms
    @medium = Media.find_by_name("Other Media")
    fandoms_for_media
  end

  def rpf_fandoms
    @medium = Media.find_by_name("Celebrities & Real People")
    fandoms_for_media
  end

  def theater_fandoms
    @medium = Media.find_by_name("Theater")
    fandoms_for_media
  end

  def tv_fandoms
    @medium = Media.find_by_name("TV Shows")
    fandoms_for_media
  end

  def video_game_fandoms
    @medium = Media.find_by_name("Video Games")
    fandoms_for_media
  end

  def fandoms_for_media
    @media = Media.canonical - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
    @fandoms = @medium.fandoms.where(:canonical => true) if @medium
    @fandoms = (@fandoms || Fandom).where("filter_taggings.inherited = 0").
                for_collections([@collection]).
                select("tags.*, count(tags.id) as count").
                group(:id).
                order("TRIM(LEADING 'a ' FROM TRIM(LEADING 'an ' FROM TRIM(LEADING 'the ' FROM LOWER(name))))")
    @fandoms_by_letter = @fandoms.group_by {|f| f.name.sub(/^(the|a|an)\s+/i, '')[0].upcase}
    render :fandoms
  end

  def madness
  end

protected

  def load_yuletide  
    @collection = Collection.find_by_name("yuletide2010")
    !@collection.unrevealed? || access_denied
  end
    
  def require_login  
    logged_in? || logged_in_as_admin? || access_denied
  end
  
end
