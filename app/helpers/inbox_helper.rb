module InboxHelper
  # Describes commentable - used on inbox show page
  def commentable_description_link(comment)
    commentable = comment.ultimate_parent
    return ts("Deleted Object") if commentable.blank?

    if commentable.is_a?(Tag)
      link_to commentable.name, tag_comment_path(commentable, comment)
    elsif commentable.is_a?(AdminPost)
      link_to commentable.title, admin_post_comment_path(commentable, comment)
    else
      link_to commentable.title, work_comment_path(commentable, comment)
    end
  end
  
  # get_commenter_pseud_or_name can be found in comments_helper
  
  def inbox_reply_link(comment)
    if comment.depth > ArchiveConfig.COMMENT_THREAD_MAX_DEPTH
      fallback_url = url_for(comment_path(comment, :add_comment_reply_id => comment.id, :anchor => 'comment_' + comment.id.to_s))
    else
      fallback_url = fallback_url_for_comment(comment, {:add_comment_reply_id => comment.id})
    end    
    link_to "Reply", {:url => reply_user_inbox_path(current_user, :comment_id => comment), :method => :get}, :remote => true, :href => fallback_url
  end
  
end
