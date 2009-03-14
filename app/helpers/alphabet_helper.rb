module AlphabetHelper
  
  def link_to_letter(letter, text = "")
    link_to_unless_current(text.blank? ? letter : text, url_for(:overwrite_params => {:letter => letter}))
  end
  
  def alpha_paginated_section(alphabet = User::ALPHABET)
    return "" if alphabet.blank? 
    block = '<div class="pagination">'
    active_letter = params[:letter] || alphabet[0]
    return "" if active_letter.nil? 
    active_letter_index = alphabet.index(active_letter.upcase) || 0
    previous_letter = alphabet[active_letter_index-1]
    next_letter = alphabet[active_letter_index+1]

    # if there is no "previous" page, don't link
    unless active_letter_index == 0
      block << '<span class="prev_page">'
      block << link_to_letter(previous_letter, '&laquo; ' + 'Previous')
      block << '</span>'
    else
      block << '<span class="disabled prev_page">&laquo; ' + 'Previous' + '</span>'
    end

    # Link all the letters
    alphabet.each do |letter|
      unless letter == active_letter
        block << " " + link_to_letter(letter.upcase)
      else
        block << ' <span class="current">' + letter.upcase + '</span>'
      end
    end

    unless active_letter_index == (alphabet.size-1)
      block << ' <span class="next_page">'
      block << link_to_letter(next_letter, 'Next' + ' &raquo;')
      block << '</span>'
    else
      block << ' <span class="disabled prev_page">' + 'Next' + ' &raquo;' + '</span>'
    end

    block << "</div>"
  end

  
end