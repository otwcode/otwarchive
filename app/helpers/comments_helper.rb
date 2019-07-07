module CommentsHelper

  def value_for_comment_form(commentable, comment)
    commentable.is_a?(Tag) ? comment : [commentable, comment]
  end

  def title_for_comment_page(commentable)
    if commentable.commentable_name.blank?
      title = ""
    elsif commentable.is_a?(Tag)
      title = link_to_tag(commentable)
    else
      title = link_to(commentable.commentable_name, commentable)
    end
    (ts('Reading Comments on ') + title).html_safe
  end

  def last_reply_by(comment)
    if comment.count_all_comments > 0
      c = Comment.where(thread: comment.id).order(created_at: :desc).first
      if c.pseud
        link_to c.pseud.name, [c.pseud.user, c.pseud]
      else
        c.name
      end
    end
  end

  def link_to_comment_ultimate_parent(comment)
    ultimate = comment.ultimate_parent
    case ultimate.class.to_s
      when 'Work' then
        link_to ultimate.title, ultimate
      when 'Pseud' then
        link_to ultimate.name, ultimate
      when 'AdminPost' then
          link_to ultimate.title, ultimate
      else
        if ultimate.is_a?(Tag)
          link_to_tag(ultimate)
        else
          link_to 'Something Interesting', ultimate
        end
    end
  end

  # return pseudname or name for comment
  def get_commenter_pseud_or_name(comment)
    if comment.pseud_id
      if comment.pseud.nil?
        ts("Account Deleted")
      else
        link_to comment.pseud.byline, [comment.pseud.user, comment.pseud]
      end
    else
      comment.name
    end
  end

  ####
  ## Mar 4 2009 Enigel: the below shouldn't happen anymore, please test
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
  def show_hide_comments_link(commentable, options={})
    options[:link_type] ||= "show"
    options[:show_count] ||= false

    commentable_id = commentable.is_a?(Tag) ?
                      :tag_id :
                      "#{commentable.class.to_s.underscore}_id".to_sym
    commentable_value = commentable.is_a?(Tag) ?
                          commentable.name :
                          commentable.id

    comment_count = commentable.count_visible_comments.to_s

    link_action = options[:link_type] == "hide" || params[:show_comments] ?
                    :hide_comments :
                    :show_comments

    link_text = ts("%{words} %{count}",
                  words: options[:link_type] == "hide" || params[:show_comments] ?
                              "Hide Comments" :
                              "Comments",
                  count: options[:show_count] ?
                              "(" +comment_count+ ")" :
                              "")

    link_to(
        link_text,
        url_for(controller: :comments,
                action: link_action,
                commentable_id => commentable_value,
                view_full_work: params[:view_full_work]),
        remote: true)
  end

  #### HELPERS FOR CHECKING WHICH BUTTONS/FORMS TO DISPLAY #####

  def can_reply_to_comment?(comment)
    !(comment.unreviewed? || no_anon_reply(comment) || comment_parent_hidden?(comment))
  end

  def can_edit_comment?(comment)
    is_author_of?(comment) && comment.count_all_comments == 0 && !comment_parent_hidden?(comment)
  end

  def comment_parent_hidden?(comment)
    parent = comment.ultimate_parent
    (parent.respond_to?(:hidden_by_admin) && parent.hidden_by_admin) ||
      (parent.respond_to?(:in_unrevealed_collection) && parent.in_unrevealed_collection)
  end

  def no_anon_reply(comment)
    comment.ultimate_parent.is_a?(Work) && comment.ultimate_parent.anon_commenting_disabled && !logged_in?
  end

  #### HELPERS FOR REPLYING TO COMMENTS #####

  def add_cancel_comment_reply_link(comment)
    if params[:add_comment_reply_id] && params[:add_comment_reply_id] == comment.id.to_s
      cancel_comment_reply_link(comment)
    else
      add_comment_reply_link(comment)
    end
  end

  # return link to add new reply to a comment
  def add_comment_reply_link(comment)
    commentable_id = comment.ultimate_parent.is_a?(Tag) ?
                        :tag_id :
                        comment.parent.class.name.foreign_key.to_sym # :chapter_id, :admin_post_id etc.
    commentable_value = comment.ultimate_parent.is_a?(Tag) ?
                          comment.ultimate_parent.name :
                          comment.parent.id
    link_to(
      ts("Reply"),
      url_for(controller: :comments,
              action: :add_comment_reply,
              id: comment.id,
              comment_id: params[:comment_id],
              commentable_id => commentable_value,
              view_full_work: params[:view_full_work],
              page: params[:page]),
      remote: true)
  end

  # return link to cancel new reply to a comment
  def cancel_comment_reply_link(comment)
    commentable_id = comment.ultimate_parent.is_a?(Tag) ?
                        :tag_id :
                        comment.parent.class.name.foreign_key.to_sym
    commentable_value = comment.ultimate_parent.is_a?(Tag) ?
                          comment.ultimate_parent.name :
                          comment.parent.id
    link_to(
      ts("Cancel"),
      url_for(controller: :comments,
              action: :cancel_comment_reply,
              id: comment.id,
              comment_id: params[:comment_id],
              commentable_id => commentable_value,
              view_full_work: params[:view_full_work],
              page: params[:page]),
      remote: true)
  end

  # TO DO: create fallbacks to support non-JavaScript requests!
  # return button to cancel adding a comment. kind of ugly because we want it
  # to work for the comment form no matter where it appears, but oh well
  def cancel_comment_button(comment, commentable)
    if comment.new_record?
      if commentable.class == comment.class
        # canceling a reply to a comment
        commentable_id = commentable.ultimate_parent.is_a?(Tag) ?
                            :tag_id :
                            "#{commentable.ultimate_parent.class.to_s.underscore}_id".to_sym
        commentable_value = commentable.ultimate_parent.is_a?(Tag) ?
                              commentable.ultimate_parent.name :
                              commentable.ultimate_parent.id
        link_to(
          ts("Cancel"),
          url_for(controller: :comments,
                  action: :cancel_comment_reply,
                  id: commentable.id,
                  comment_id: params[:comment_id],
                  commentable_id => commentable_value),
          remote: true)
       else
        # canceling a reply to a different commentable thingy
        commentable_id = commentable.is_a?(Tag) ?
                            :tag_id :
                            "#{commentable.class.to_s.underscore}_id".to_sym
        commentable_value = commentable.is_a?(Tag) ?
                              commentable.name :
                              commentable.id
        link_to(
          ts("Cancel"),
          url_for(controller: :comments,
                  action: :cancel_comment,
                  commentable_id => commentable_value),
          remote: true)
      end
    else
      # canceling an edit
      link_to(
        ts("Cancel"),
        url_for(controller: :comments,
                action: :cancel_comment_edit,
                id: (comment.id),
                comment_id: params[:comment_id]),
        remote: true)
    end
  end

  # return html link to edit comment
  def edit_comment_link(comment)
    link_to(ts("Edit"),
            url_for(controller: :comments,
                    action: :edit,
                    id: comment,
                    comment_id: params[:comment_id]),
            remote: true)
  end

  def do_cancel_delete_comment_link(comment)
    if params[:delete_comment_id] && params[:delete_comment_id] == comment.id.to_s
      cancel_delete_comment_link(comment)
    else
      delete_comment_link(comment)
    end
  end

  # return html link to delete comments
  def delete_comment_link(comment)
    link_to(
      ts("Delete"),
      url_for(controller: :comments,
              action: :delete_comment,
              id: comment,
              comment_id: params[:comment_id]),
      remote: true)
  end

  # return link to cancel new reply to a comment
  def cancel_delete_comment_link(comment)
    link_to(
      ts("Cancel"),
      url_for(controller: :comments,
              action: :cancel_comment_delete,
              id: comment,
              comment_id: params[:comment_id]),
      remote: true)
  end

  # return html link to mark/unmark comment as spam
  def tag_comment_as_spam_link(comment)
    if comment.approved
      link_to(ts("Spam"), reject_comment_path(comment), method: :put, confirm: "Are you sure you want to mark this as spam?" )
    else
      link_to(ts("Not Spam"), approve_comment_path(comment), method: :put)
    end
  end

  # non-JavaScript fallbacks for great justice!

  def fallback_url_for_top_level(commentable, options = {})
    default_options = {anchor: "comments"}
    if commentable.is_a?(Tag)
      default_options[:controller] = :comments
      default_options[:action] = :index
      default_options[:tag_id] = commentable.name
    else
      default_options[:controller] = commentable.class.to_s.underscore.pluralize
      default_options[:action] = "show"
      default_options[:id] = commentable.id
    end
    default_options[:add_comment] = params[:add_comment] if params[:add_comment]
    default_options[:show_comments] = params[:show_comments] if params[:show_comments]

    options = default_options.merge(options)
    url_for(options)
  end

  def fallback_url_for_comment(comment, options = {})
    default_options = {anchor: "comment_#{comment.id}"}
    default_options[:action] = "show"
    default_options[:show_comments] = true
    default_options[:id] = comment.id if comment.ultimate_parent.is_a?(Tag)

    options = default_options.merge(options)

    if @thread_view # hopefully means we're on a Thread page
      options[:id] = @thread_root if @thread_root
      url_for(options)
    else # Top Level Commentable
      fallback_url_for_top_level(comment.ultimate_parent, options)
    end

  end

  # find the parent of the commentable
  def find_parent(commentable)
    if commentable.is_a?(Comment)
      commentable.ultimate_parent
    elsif commentable.respond_to?(:work)
      commentable.work
    else
      commentable
    end
  end

  # if parent commentable is a work, determine if current user created it
  def current_user_is_work_creator(commentable)
    if logged_in?
      parent = find_parent(commentable)
      parent.is_a?(Work) && current_user.is_author_of?(parent)
    end
  end

  # if parent commentable is an anonymous work, determine if current user created it
  def current_user_is_anonymous_creator(commentable)
    if logged_in?
      parent = find_parent(commentable)
      parent.is_a?(Work) && parent.anonymous? && current_user.is_author_of?(parent)
    end
  end

  # determine if the parent has its comments set to moderated
  def comments_are_moderated(commentable)
    parent = find_parent(commentable)
    parent.respond_to?(:moderated_commenting_enabled) && parent.moderated_commenting_enabled?
  end

end
