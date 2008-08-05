module PoemAdditions
  def text_with_div
    "<div>#{text}</div>"
  end
end

Poem.class_eval { include PoemAdditions }

Streamlined.ui_for(Poem) do
  list_columns :text,
               :text_with_div,
               :poet, { :filter_column => "first_name" }
end