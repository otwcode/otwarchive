class TagWranglersController < ApplicationController
  include ExportsHelper
  include WranglingHelper

  before_action :check_user_status
  before_action :check_permission_to_wrangle, except: [:report_csv]

  def index
    authorize :wrangling, :full_access? if logged_in_as_admin?

    @wranglers = Role.find_by(name: "tag_wrangler").users.alphabetical
    conditions = ["canonical = 1"]
    joins = "LEFT JOIN wrangling_assignments ON (wrangling_assignments.fandom_id = tags.id)
             LEFT JOIN users ON (users.id = wrangling_assignments.user_id)"
    unless params[:fandom_string].blank?
      conditions.first << " AND name LIKE ?"
      conditions << params[:fandom_string] + "%"
    end
    unless params[:wrangler_id].blank?
      if params[:wrangler_id] == "No Wrangler"
        conditions.first << " AND users.id IS NULL"
      else
        @wrangler = User.find_by(login: params[:wrangler_id])
        if @wrangler
          conditions.first << " AND users.id = #{@wrangler.id}"
        end
      end
    end
    unless params[:media_id].blank?
      @media = Media.find_by_name(params[:media_id])
      if @media
        joins << " INNER JOIN common_taggings ON (tags.id = common_taggings.common_tag_id)"
        conditions.first << " AND common_taggings.filterable_id = #{@media.id} AND common_taggings.filterable_type = 'Tag'"
      end
    end
    @assignments = Fandom.in_use.joins(joins)
                                .select('tags.*, users.login AS wrangler')
                                .where(conditions)
                                .order(:name)
                                .paginate(page: params[:page], per_page: 50)
  end

  def show
    authorize :wrangling if logged_in_as_admin?

    @wrangler = User.find_by!(login: params[:id])
    @page_subtitle = @wrangler.login
    @fandoms = @wrangler.fandoms.by_name
    @counts = tag_counts_per_category
  end

  def report_csv
    authorize :wrangling

    wrangler = User.find_by!(login: params[:id])
    wrangled_tags = Tag
      .where(last_wrangler: wrangler)
      .limit(ArchiveConfig.WRANGLING_REPORT_LIMIT)
      .includes(:merger, :parents)
    results = [%w[Name Last\ Updated Type Merger Fandoms Unwrangleable]]
    wrangled_tags.find_each(order: :desc) do |tag|
      merger = tag.merger&.name || ""
      fandoms = tag.parents.filter_map { |parent| parent.name if parent.is_a?(Fandom) }.join(", ")
      results << [tag.name, tag.updated_at, tag.type, merger, fandoms, tag.unwrangleable]
    end
    filename = "wrangled_tags_#{wrangler.login}_#{Time.now.utc.strftime('%Y-%m-%d-%H%M')}.csv"
    send_csv_data(results, filename)
  end

  def create
    authorize :wrangling if logged_in_as_admin?

    unless params[:tag_fandom_string].blank?
      names = params[:tag_fandom_string].gsub(/$/, ',').split(',').map(&:strip)
      fandoms = Fandom.where('name IN (?)', names)
      unless fandoms.blank?
        for fandom in fandoms
          unless !current_user.respond_to?(:fandoms) || current_user.fandoms.include?(fandom)
            assignment = current_user.wrangling_assignments.build(fandom_id: fandom.id)
            assignment.save!
          end
        end
      end
    end
    unless params[:assignments].blank?
      params[:assignments].each_pair do |fandom_id, user_logins|
        fandom = Fandom.find(fandom_id)
        user_logins.uniq.each do |login|
          unless login.blank?
            user = User.find_by(login: login)
            unless user.nil? || user.fandoms.include?(fandom)
              assignment = user.wrangling_assignments.build(fandom_id: fandom.id)
              assignment.save!
            end
          end
        end
      end
      flash[:notice] = "Wranglers were successfully assigned!"
    end
    redirect_to tag_wranglers_path(media_id: params[:media_id], fandom_string: params[:fandom_string], wrangler_id: params[:wrangler_id])
  end

  def destroy
    authorize :wrangling if logged_in_as_admin?

    wrangler = User.find_by(login: params[:id])
    assignment = WranglingAssignment.where(user_id: wrangler.id, fandom_id: params[:fandom_id]).first
    assignment.destroy
    flash[:notice] = "Wranglers were successfully unassigned!"
    redirect_to tag_wranglers_path(media_id: params[:media_id], fandom_string: params[:fandom_string], wrangler_id: params[:wrangler_id])
  end
end
