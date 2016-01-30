module StatsHelper

  def stats_view(view_type)
    if view_type == "invitations"
      render :partial => 'invitation_stats'    
    elsif view_type == "users"
      render :partial => 'user_stats'
    elsif view_type == "works"
      render :partial => 'work_stats'
    elsif view_type == "tags"
      render :partial => 'tag_stats'
    else
      ''
    end
  end

end
