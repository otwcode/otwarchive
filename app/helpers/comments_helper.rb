module CommentsHelper

  # return pseudname or email address for comment
  def get_pseud_or_mailaddress(comment)
    if comment.pseud_id
      link_to comment.pseud.name, comment.pseud.user
    else
      comment.name
    end
  end 
  
  # return 'cancel' button to clear form or restore existing comment
  def create_cancel_button(comment, commentable)
    if comment.new_record?
      if commentable.class == comment.class
        button_to_function "Cancel".t, update_page {|page| page.replace_html "add_comment_#{commentable.class.to_s.downcase}_#{commentable.id}" }
      else
        button_to_function "Cancel".t, update_page {|page| page.hide "add_comment_#{commentable.class.to_s.downcase}_#{commentable.id}" }
      end
    else
      button_to_function "Cancel".t, update_page {|page| page.replace_html "data_for_comment_#{comment.id}", 
                          :partial => 'comments/single_comment', :locals => {:single_comment => comment}}
    end
  end
  
  # return html link to add new comment
  def create_add_comment_link(commentable)
    if commentable.is_a?(Work)
      href = {:controller => :comments, :action => :new, :work_id => commentable}
    else
      href = eval("new_#{commentable.class.to_s.downcase}_comment_path(commentable)")
    end
    link_to_remote "Leave feedback".t, {:url => href, :method => :get}, :href => href  
  end
  
  # return link to show or hide comments
  def show_hide_comments_link(commentable, is_work)
    if is_work
      commentable = @work
    end
    commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
    if params[:show_comments] || (@show_comments ||= false)
      link_to "Hide Feedback".t, :controller => commentable.class.to_s.pluralize, :action => :show, :id => commentable.id
    else
      link_to_remote("Read feedback (#{commentable.count_visible_comments})".t, {:url =>{ :controller => :comments, :action => :index, commentable_id => (commentable.id)}, :method => :get}, :href => url_for(:controller => commentable.class.to_s.pluralize, :action => 'show', :id => commentable.id, :show_comments => true))
    end   
  end
  
  # return html link to unhide reply-to-comment-form
  def create_reply_link(comment, controller_name="comments")
    link_to_remote "Reply".t, {:url => {:controller => :comments, :action => :new, :comment_id => comment, :controller_name => controller_name}, :method => :get}, 
      :href => new_comment_comment_path(comment)
  end
  
  # return html link to edit comment
  def create_edit_link(comment)
    if comment.count_all_comments == 0
      link_to_remote "Edit".t, {:url => edit_comment_path(comment), :method => :get}, 
        :href => edit_comment_path(comment)
    end
  end
  
  # return html link to delete comments
  def create_destroy_link(comment)
    link_to 'Destroy'.t, comment,
      :confirm => 'Are you sure?'.t, 
      :method => :delete
  end
  
  # return html link to mark/unmark comment as spam
  def create_tag_as_spam_link(comment)
    if comment.approved
      link_to 'Spam'.t, reject_comment_path(comment), :method => :put
    else
      link_to 'Not Spam'.t, approve_comment_path(comment), :method => :put 
    end
  end

  # print count "</divs>"
  def print_closing_divs(count)
    divs = ""
    (count).times { divs += "</div>\n" }
    divs
  end
  
end
