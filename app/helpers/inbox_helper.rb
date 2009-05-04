module InboxHelper
  # Describes commentable - used on inbox show page
  def commentable_description_link(comment)
    name = comment.ultimate_parent.title
    link_to name, work_comment_path(comment.ultimate_parent, comment)
  end
  
  def commentable_owner_link(comment)
    if comment.pseud.nil?
      return comment.name
    else
      return link_to(comment.pseud.byline, [comment.pseud.user, comment.pseud])
    end
  end
  
  def inbox_reply_link(comment)
    if comment.depth > ArchiveConfig.COMMENT_THREAD_MAX_DEPTH
      fallback_url = url_for(comment_path(comment, :add_comment_reply_id => comment.id, :anchor => 'comment' + comment.id.to_s))
    else
      fallback_url = fallback_url_for_comment(comment, {:add_comment_reply_id => comment.id})
    end    
    link_to_remote "Reply", {:url => reply_user_inbox_path(current_user, :comment_id => comment), :method => :get}, :href => fallback_url
  end
  
end
