module CommentsHelper

  # return pseudname or email adress for comment
  def get_pseud_or_mailaddress(comment)
    if comment.pseud_id
      link_to comment.pseud.name, comment
    else
      mail_to comment.email, comment.name
    end
  end
  
  # return html link to unhide reply-to-comment-form
  def create_reply_link(comment)
    link_to_function "Reply".t, 
      update_page {|page| page.replace_html "add-comment#{comment.id}",
      :partial => @comment = Comment.new,
      :locals => {:commentable => comment, :button_name => 'Create'}}, 
      :href => new_comment_comment_path(comment)
  end
  
  # return html link to edit comment
  def create_edit_link(comment)
    link_to_function "Edit",
      update_page {|page| page.replace_html "comment#{comment.id}",
      :partial => @comment = comment,
      :locals => {:commentable => comment.commentable, :button_name => 'Update'}}, 
      :href => edit_comment_path(comment)
  end
  
  # return html link to delete comments
  def create_destroy_link(comment)
    link_to 'Destroy', comment,
      :confirm => 'Are you sure?', 
      :method => :delete
  end
  
  # return html link to mark/unmark comment as spam
  def create_tag_as_spam_link(comment)
    if comment.approved
      link_to 'Spam', reject_comment_path(comment), :method => :put
    else
      link_to 'Not Spam', approve_comment_path(comment), :method => :put 
    end
  end

  # print count "</divs>"
  def print_closing_divs(count)
    divs = ""
    (count).times { divs += "</div>\n" }
    divs
  end
  
end
