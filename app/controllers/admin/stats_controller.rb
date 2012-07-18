class Admin::StatsController < ApplicationController

  before_filter :admin_only

  def index
    @graph_dates = []
    d = 3.months.ago.beginning_of_week
    while d < Time.now
      @graph_dates << d
      d = d + 7.days
    end
    if params[:model] == "invitations"
      @invitations_by_status = {:unsent => Invitation.unsent.count, :unredeemed => Invitation.unredeemed.count, :redeemed => Invitation.redeemed.count}
      @invitations_created_weekly = Invitation.find(:all, :select => :created_at, :conditions => ['created_at > ?', 3.months.ago]).group_by{|invitation| invitation.created_at.beginning_of_week}
      @invitations_redeemed_weekly = Invitation.redeemed.find(:all, :select => :redeemed_at, :conditions => ['redeemed_at > ?', 3.months.ago]).group_by{|invitation| invitation.redeemed_at.beginning_of_week}
    elsif params[:model] == "users"
      @users_created_weekly = User.find(:all, :select => :created_at, :conditions => ['created_at > ?', 3.months.ago]).group_by{|user| user.created_at.beginning_of_week}
    elsif params[:model] == "works"
      @works_created_weekly = Work.find(:all, :select => :created_at, :conditions => ['created_at > ?', 3.months.ago]).group_by{|work| work.created_at.beginning_of_week}
    elsif params[:model] == "tags"
    end
  end
end
