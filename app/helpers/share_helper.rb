module ShareHelper

  # get work title, word count, and creator and add app short name, but do not add formatting so it can be link text for Tumblr sharing
  def get_tumblr_embed_link_title(work)
    title = work.title + " (#{work.word_count} #{ts('words')})"
    if work.anonymous?
      pseud = ts("Anonymous")
    else
      pseud = work.pseuds.pluck(:name).join(', ')
    end
    "#{title} #{ts("by")} #{pseud} #{ts("[#{ArchiveConfig.APP_SHORT_NAME}]")}"
  end
  
  def get_tweet_text(work)
    if work.unrevealed?
      ts("Mystery Work")
    else
      names = work.anonymous? ? ts("Anonymous") : work.pseuds.pluck(:name).join(', ')
      fandoms = work.fandoms.size > 2 ? ts("Multifandom") : work.fandoms.string
      "#{work.title} by #{names} - #{fandoms}".truncate(95)
    end
  end
  
  def get_tweet_text_for_bookmark(bookmark)
    if bookmark.bookmarkable.is_a?(Work)
      names = bookmark.bookmarkable.anonymous? ? ts("Anonymous") : bookmark.bookmarkable.pseuds.pluck(:name).join(', ')
      fandoms = bookmark.bookmarkable.fandoms.size > 2 ? ts("Multifandom") : bookmark.bookmarkable.fandoms.string
      "Bookmark of #{bookmark.bookmarkable.title} by #{names} - #{fandoms}".truncate(83)
    end
  end

  # Being able to add line breaks in the sharing templates makes the code
  # easier to read and edit, but we don't want them in the sharing code itself
  def remove_newlines(html)
    html.gsub("\n", "")
  end
  
end
