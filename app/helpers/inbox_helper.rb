module InboxHelper
  # Describes commentable - used on inbox show page
  def commentable_description_link(comment)
    if comment.commentable_type == "Work"
      name = "your story".t + " '" + comment.commentable.title + "'"
    elsif comment.commentable_type == "Chapter"
      name = "Chapter ".t + comment.commentable.position.to_s + " of your story".t + " '" + comment.commentable.work.title + "'"
    else
      name = "your ".t + comment.commentable_type.downcase
    end
    link_to name, comment.commentable
  end
end
