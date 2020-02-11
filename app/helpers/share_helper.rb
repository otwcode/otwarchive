# frozen_string_literal: true

# Helper for work and bookmark social media sharing code
module ShareHelper
  # get work title, word count, and creator and add app short name, but do not add formatting so it can be link text for Tumblr sharing
  def get_tumblr_embed_link_title(work)
    title = work.title + " (#{work.word_count} #{ts('words')})"
    pseud = text_byline(work)
    "#{title} #{ts("by")} #{pseud} #{ts("[#{ArchiveConfig.APP_SHORT_NAME}]")}"
  end
  
  def get_tweet_text(work)
    if work.unrevealed?
      ts("Mystery Work")
    else
      names = text_byline(work)
      fandoms = work.short_fandom_string
      "#{work.title} by #{names} - #{fandoms}".truncate(95)
    end
  end
  
  def get_tweet_text_for_bookmark(bookmark)
    return unless bookmark.bookmarkable.is_a?(Work)

    names = bookmark.bookmarkable.creators.to_sentence
    fandoms = bookmark.bookmarkable.short_fandom_string
    "Bookmark of #{bookmark.bookmarkable.title} by #{names} - #{fandoms}".truncate(83)
  end

  # Being able to add line breaks in the sharing templates makes the code
  # easier to read and edit, but we don't want them in the sharing code itself
  def remove_newlines(html)
    html.gsub("\n", "")
  end
end
