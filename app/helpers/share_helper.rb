# Helper for work and bookmark social media sharing code
module ShareHelper
  # Get work title, word count, and creators and add app short name,
  # but do not add formatting so it can be link text for Tumblr sharing.
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
      fandoms = short_fandom_string(work)
      "#{work.title} by #{names} - #{fandoms}".truncate(95)
    end
  end

  def get_tweet_text_for_bookmark(bookmark)
    return unless bookmark.bookmarkable.is_a?(Work)

    names = bookmark.bookmarkable.creators.to_sentence
    fandoms = short_fandom_string(bookmark.bookmarkable)
    "Bookmark of #{bookmark.bookmarkable.title} by #{names} - #{fandoms}".truncate(83)
  end

  # JavaScript-less share buttons from https://sharingbuttons.io/
  # We use medium, solid, rectangular buttons.
  def sharing_button(site, address, text, target: nil)
    return unless %w[bluesky twitter tumblr].include?(site)

    tag.a(
      tag.div(
        tag.div(
          sharing_svg(site),
          class: "resp-sharing-button__icon resp-sharing-button__icon--solid",
          aria: { hidden: true }
        ) + text,
        class: "resp-sharing-button resp-sharing-button--#{site} resp-sharing-button--medium"
      ),
      href: address,
      target: target,
      class: "resp-sharing-button__link",
      aria: { label: text }
    )
  end

  private

  def short_fandom_string(work)
    work.fandoms.size > 2 ? ts("Multifandom") : work.fandom_string
  end

  # Being able to add line breaks in the sharing templates makes the code
  # easier to read and edit, but we don't want them in the sharing code itself
  def remove_newlines(html)
    html.delete("\n")
  end

  def sharing_svg(site)
    return unless %w[bluesky twitter tumblr].include?(site)

    path = case site
           when "bluesky"
             tag.path d: "M12 10.8c-1.087 -2.114 -4.046 -6.053 -6.798 -7.995C2.566 0.944 1.561 1.266 0.902 1.565 0.139 1.908 0 3.08 0 3.768c0 0.69 0.378 5.65 0.624 6.479 0.815 2.736 3.713 3.66 6.383 3.364 0.136 -0.02 0.275 -0.039 0.415 -0.056 -0.138 0.022 -0.276 0.04 -0.415 0.056 -3.912 0.58 -7.387 2.005 -2.83 7.078 5.013 5.19 6.87 -1.113 7.823 -4.308 0.953 3.195 2.05 9.271 7.733 4.308 4.267 -4.308 1.172 -6.498 -2.74 -7.078a8.741 8.741 0 0 1 -0.415 -0.056c0.14 0.017 0.279 0.036 0.415 0.056 2.67 0.297 5.568 -0.628 6.383 -3.364 0.246 -0.828 0.624 -5.79 0.624 -6.478 0 -0.69 -0.139 -1.861 -0.902 -2.206 -0.659 -0.298 -1.664 -0.62 -4.3 1.24C16.046 4.748 13.087 8.687 12 10.8Z"
           when "twitter"
             tag.path d: "M23.44 4.83c-.8.37-1.5.38-2.22.02.93-.56.98-.96 1.32-2.02-.88.52-1.86.9-2.9 1.1-.82-.88-2-1.43-3.3-1.43-2.5 0-4.55 2.04-4.55 4.54 0 .36.03.7.1 1.04-3.77-.2-7.12-2-9.36-4.75-.4.67-.6 1.45-.6 2.3 0 1.56.8 2.95 2 3.77-.74-.03-1.44-.23-2.05-.57v.06c0 2.2 1.56 4.03 3.64 4.44-.67.2-1.37.2-2.06.08.58 1.8 2.26 3.12 4.25 3.16C5.78 18.1 3.37 18.74 1 18.46c2 1.3 4.4 2.04 6.97 2.04 8.35 0 12.92-6.92 12.92-12.93 0-.2 0-.4-.02-.6.9-.63 1.96-1.22 2.56-2.14z"
           when "tumblr"
             tag.path d: "M13.5.5v5h5v4h-5V15c0 5 3.5 4.4 6 2.8v4.4c-6.7 3.2-12 0-12-4.2V9.5h-3V6.7c1-.3 2.2-.7 3-1.3.5-.5 1-1.2 1.4-2 .3-.7.6-1.7.7-3h3.8z"
           end

    tag.svg(
      path,
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24"
    )
  end
end
