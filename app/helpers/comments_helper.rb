module CommentsHelper

  def link_to_comment_ultimate_parent(comment)
    ultimate = comment.ultimate_parent
    case ultimate.type 
      when "Chapter" then
        link_to ultimate.work.title, ultimate
      when "Pseud" then
        link_to ultimate.name, ultimate
    end
  end

  # return pseudname or email address for comment
  def get_pseud_or_mailaddress(comment)
    if comment.pseud_id
      link_to comment.pseud.name, comment.pseud.user
    else
      comment.name
    end
  end 

  
  ####
  ## Note: there is a small but interesting bug here. If you first use javascript to open
  ## up the comments, the various url_for(:overwrite_params) arguments used below as the
  ## non-javascript fallbacks will end up with the wrong code, and so if you then turn
  ## off Javascript and try to use the links, you will get weirdo results. I think this
  ## is a bug we can live with for the moment; someone consistently browsing without
  ## javascript shouldn't have problems.
  ## -- Naomi, 9/2/2008
  ####
  
  #### Helpers for _commentable.html.erb ####

  # return link to show or hide comments
  def show_hide_comments_link(commentable)
    if params[:show_comments]
      hide_comments_link(commentable)
    else
      show_comments_link(commentable)
    end 
  end
  
  def show_comments_link(commentable)
    commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
    link_to_remote(
        "Read Comments".t,
        {:url => { :controller => :comments, :action => :show_comments, commentable_id => (commentable.id)}, :method => :get}, 
        :href => url_for(:overwrite_params => {:show_comments => true}, :anchor => "comments") ) +
    '&nbsp;' + '(%d comments)'/commentable.count_visible_comments
  end
  # this comment is here just to fix aptana code coloring after the / 
    
  def hide_comments_link(commentable) 
    commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
    link_to_remote("Hide Comments".t, 
      {:url => { :controller => :comments, :action => :hide_comments, commentable_id => (commentable.id)}, :method => :get },     
      :href => url_for(:overwrite_params => {:show_comments => nil}, :anchor => "comments") )
  end
  
  # return the appropriate link to add or cancel adding a new comment (note: ONLY in _commentable.html.erb!)
  def add_cancel_comment_link(commentable)  
    if params[:add_comment]
      cancel_comment_link(commentable)
    else
      add_comment_link(commentable)
    end     
  end
  
  # return html link to add new comment on a commentable object
  def add_comment_link(commentable)
    commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
    link_to_remote(
      "Add Comment".t,
        {:url => { :controller => :comments, :action => :add_comment, commentable_id => (commentable.id)}, :method => :get}, 
        :href => url_for(:overwrite_params => {:add_comment => true}, :anchor => "comments") )
  end
      
  def cancel_comment_link(commentable)
    commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
    link_to_remote(
      "Cancel Comment".t,
        {:url => { :controller => :comments, :action => :cancel_comment, commentable_id => (commentable.id)}, :method => :get}, 
      :href => url_for(:overwrite_params => {:add_comment => nil}, :anchor => "comments") )
  end

      
  #### HELPERS FOR REPLYING TO COMMENTS #####

  # return link to add new reply to a comment
  def add_comment_reply_link(comment)
    "(" + 
    link_to_remote( 
      "Reply".t, 
      {:url => {:controller => :comments, :action => :add_comment_reply, :comment_id => comment}, :method => :get}, 
      :href => url_for(:overwrite_params => {:add_comment_reply_id => comment.id}, :anchor => "comment#{comment.id}") ) +
     ")"
  end  
  
  # return link to add new reply to a comment
  def cancel_comment_reply_link(comment)
    "(" + 
    link_to_remote( 
      "Cancel".t, 
      {:url => {:controller => :comments, :action => :cancel_comment_reply, :comment_id => comment}, :method => :get}, 
      :href => url_for(:overwrite_params => {:add_comment_reply_id => nil}) ) +
     ")"
  end  
  

#  # return 'cancel' button to clear form or restore existing comment
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


#    if commentable.is_a?(Work)
#      href = {:controller => :comments, :action => :new, :work_id => commentable}
#    else
#      href = eval("new_#{commentable.class.to_s.downcase}_comment_path(commentable)")
#    end
#    link_to_remote "Leave feedback".t, {:url => href, :method => :get}, :href => href  
#  end
  
  # return html link to unhide reply-to-comment-form
  def create_reply_link(comment, controller_name="comments")
    link_to_remote "Reply".t, {:url => {:controller => :comments, :action => :new, :comment_id => comment, :controller_name => controller_name}, :method => :get}, 
      :href => url_for(:overwrite_params => {:add_comment => true, :class => commentable.class.to_s.downcase, :comment_on => commentable.id})
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
