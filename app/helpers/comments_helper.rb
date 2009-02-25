module CommentsHelper

  def link_to_comment_ultimate_parent(comment)
    ultimate = comment.ultimate_parent
    case ultimate.class.to_s 
      when 'Work' then 
        link_to sanitize(ultimate.title, :tags => %w(em i b strong strike small)), ultimate
      when 'Pseud' then
        link_to sanitize(ultimate.name), ultimate
      else
        link_to 'Something Interesting'.t, ultimate
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
    if commentable.count_visible_comments > 0
      commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
      #Added if/else to get singular agreement for one comment
        if commentable.count_visible_comments == 1
          link_to_remote(
              "Read Comments".t,
              {:url => { :controller => :comments, :action => :show_comments, commentable_id => (commentable.id)}, :method => :get}, 
              :href => url_for(:overwrite_params => {:show_comments => true}, :anchor => "comments") ) +
          '&nbsp;' + '(%d comment)'/commentable.count_visible_comments
        # this comment is here just to fix aptana code coloring after the / 
        else
          link_to_remote(
              "Read Comments".t,
              {:url => { :controller => :comments, :action => :show_comments, commentable_id => (commentable.id)}, :method => :get}, 
              :href => url_for(:overwrite_params => {:show_comments => true}, :anchor => "comments") ) +
          '&nbsp;' + '(%d comments)'/commentable.count_visible_comments
        # this comment is here just to fix aptana code coloring after the / 
      end
    end
  end
    
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
  
  # return link to cancel new reply to a comment
  def cancel_comment_reply_link(comment)
    "(" + 
    link_to_remote( 
      "Cancel".t, 
      {:url => {:controller => :comments, :action => :cancel_comment_reply, :comment_id => comment}, :method => :get}, 
      :href => url_for(:overwrite_params => {:add_comment_reply_id => nil}) ) +
     ")"
  end  

  # return button to cancel adding a comment. kind of ugly because we want it
  # to work for the comment form no matter where it appears, but oh well
  def cancel_comment_button(comment, commentable)
    if comment.new_record?
      if commentable.class == comment.class
        # canceling a reply to a comment
        submit_to_remote( 
          'cancel', "Cancel".t, 
           :url => {:controller => :comments, :action => :cancel_comment_reply, :comment_id => commentable.id}, :method => :get, 
           :href => url_for(:overwrite_params => {:add_comment_reply_id => nil}) )
      else
        # canceling a reply to a different commentable thingy
        commentable_id = eval(":#{commentable.class.to_s.downcase}_id")
        submit_to_remote(
          'cancel', "Cancel".t, 
          :url => { :controller => :comments, :action => :cancel_comment, commentable_id => (commentable.id)}, :method => :get, 
          :href => url_for(:overwrite_params => {:add_comment => nil}, :anchor => "comments") )
      end
    else
      # canceling an edit
      submit_to_remote(
        'cancel', "Cancel".t, 
        :url => { :controller => :comments, :action => :cancel_comment_edit, :id => (comment.id)}, :method => :get, 
        :href => url_for(:overwrite_params => {:edit_comment_id => nil}, :anchor => "comments") )
    end
  end  
    
  # return html link to edit comment
  def edit_comment_link(comment)
    if comment.count_all_comments == 0
      "(" +
      link_to_remote("Edit".t, 
        {:url => {:controller => :comments, :action => :edit, :id => comment}, :method => :get}, 
        :href => url_for(:overwrite_params => {:edit_comment_id => comment.id}, :anchor => "comment#{comment.id}") ) +
      ")"
    end
  end
  
  # return html link to delete comments
  def delete_comment_link(comment)
    "(" +
    link_to_remote( 
      "Delete".t, 
      {:url => {:controller => :comments, :action => :delete_comment, :id => comment}, :method => :get}, 
      :href => url_for(:overwrite_params => {:delete_comment_id => comment.id}, :anchor => "comment#{comment.id}") ) +
    ")"
  end

  # return link to cancel new reply to a comment
  def cancel_delete_comment_link(comment)
    "(" + 
    link_to_remote( 
      "Cancel".t, 
      {:url => {:controller => :comments, :action => :cancel_comment_delete, :id => comment}, :method => :get}, 
      :href => url_for(:overwrite_params => {:delete_comment_id => nil}, :anchor => "comment#{comment.id}") ) +
     ")"
  end    
  
  # return html link to mark/unmark comment as spam
  def tag_comment_as_spam_link(comment)
    
    if comment.approved
      "(" + link_to('Spam'.t, reject_comment_path(comment), :method => :put) + ")"
    else
      "(" + link_to('Not Spam'.t, approve_comment_path(comment), :method => :put)  + ")"
    end
  end

end
