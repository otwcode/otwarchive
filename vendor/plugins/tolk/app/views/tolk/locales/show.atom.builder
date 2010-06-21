atom_feed do |feed|
  feed.title "Missing Translations for #{@locale.language_name} locale"

  @phrases.each do |phrase|
    feed.entry(phrase, :url => tolk_locale_url(@locale)) do |entry|
      entry.title(phrase.key)
      entry.content(phrase.key)
      entry.author {|author| author.name("Tolk") }
    end
  end
end
