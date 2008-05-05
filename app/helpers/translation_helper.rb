module TranslationHelper
  
  def rows_for_words(string)
   words = (string).split(/\S+/).size
   words > 5 ? words/5 : 1
  end

end
