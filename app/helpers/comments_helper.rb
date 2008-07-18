module CommentsHelper

  # return pseudname or email address for comment
  def get_pseud_or_mailaddress(comment)
    if comment.pseud_id
      link_to comment.pseud.name, comment
    else
      comment.name
    end
  end 
  
  # return 'cancel' button to clear form or restore existing comment
  def create_cancel_button(comment, commentable)
    if comment.new_record?
      if commentable.class == comment.class
        button_to_function "Cancel", update_page {|page| page.replace_html "add_comment_#{commentable.class.to_s.downcase}_#{commentable.id}" }
      else
        button_to_function "Cancel", update_page {|page| page.hide "add_comment_#{commentable.class.to_s.downcase}_#{commentable.id}" }
      end
    else
      button_to_function "Cancel", update_page {|page| page.replace_html "data_for_comment_#{comment.id}", 
                          :partial => 'comments/single_comment', :locals => {:single_comment => comment}}
    end
  end
  
  # return html link to add new comment
  def create_add_comment_link(commentable)
    href = eval("new_#{commentable.class.to_s.downcase}_comment_path(commentable)")
    link_to_function "Add a comment".t, "Element.toggle('add_comment_#{commentable.class.to_s.downcase}_#{commentable.id}')", :href => href  
  end
  
  # return link to show or hide comments
  def show_hide_comments_link(commentable, is_work)
    if is_work
      commentable = @work
    end
    commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
    if params[:show_comments]
      link_to "Hide comments".t, :controller => commentable.class.to_s.pluralize, :action => :show, :id => commentable.id
    else
      link_to_remote("Show comments".t, {:url =>{ :controller => :comments, :action => :showcomments, commentable_id => (commentable.id)}}, :href => url_for(:controller => commentable.class.to_s.pluralize, :action => 'show', :id => commentable.id, :show_comments => true))
    end   
  end
  
  # return html link to unhide reply-to-comment-form
  def create_reply_link(comment)
    link_to_remote "Reply".t, {:url => new_comment_comment_path(comment), :method => :get}, 
      :href => new_comment_comment_path(comment)
  end
  
  # return html link to edit comment
  def create_edit_link(comment)
    link_to_remote "Edit".t, {:url => edit_comment_path(comment), :method => :get}, 
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
