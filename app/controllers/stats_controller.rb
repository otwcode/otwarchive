class StatsController < ApplicationController

  def index
    @invitations_by_status = {:unsent => Invitation.unsent.count, :unredeemed => Invitation.unredeemed.count, :redeemed => Invitation.redeemed.count}
    #@invitations_created_weekly = Invitation.find(:all, :select => :created_at, :conditions => ['created_at > ?', 3.months.ago]).group_by{|invitation| invitation.created_at.beginning_of_week}
    #@invitations_redeemed_weekly = Invitation.redeemed.find(:all, :select => :redeemed_at, :conditions => ['redeemed_at > ?', 3.months.ago]).group_by{|invitation| invitation.redeemed_at.beginning_of_week}
    #@users_created_weekly = User.find(:all, :select => :created_at, :conditions => ['created_at > ?', 3.months.ago]).group_by{|user| user.created_at.beginning_of_week}
    #@works_created_weekly = Work.find(:all, :select => :created_at, :conditions => ['created_at > ?', 3.months.ago]).group_by{|work| work.created_at.beginning_of_week}
  end

end
