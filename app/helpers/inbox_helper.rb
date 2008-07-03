module InboxHelper
  # Describes commentable - used on inbox show page
  def commentable_description_link(comment)
    if comment.commentable_type == "Work"
      name = "your story '" + comment.commentable.metadata.title + "'"
    elsif comment.commentable_type == "Chapter"
      name = "Chapter " + comment.commentable.position.to_s + " of your story '" + comment.commentable.work.metadata.title + "'"
    else
      name = "your " + comment.commentable_type.downcase
    end
    link_to name, comment.commentable
  end
end
