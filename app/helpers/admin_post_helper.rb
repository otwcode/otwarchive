module AdminPostHelper
  def sorted_translations(admin_post)
    translations = admin_post.translations
    translations = translations.posted if admin_post.posted?

    translations.sort_by do |translation|
      language = translation.language
      language.sortable_name.blank? ? language.short : language.sortable_name
    end
  end
end
