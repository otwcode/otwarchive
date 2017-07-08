module AlphabetHelper

  def link_to_letter(letter, text = "")
    link_to_unless_current(text.blank? ? letter : text, url_for(params.merge letter: letter, page: 1))
  end

  def alpha_paginated_section(alphabet = People.all.map(&:char))
    return "" if alphabet.blank?
    active_letter = params[:letter] || alphabet[0]
    return "" if active_letter.nil?
    active_letter_index = alphabet.index(active_letter.upcase) || 0
    previous_letter = alphabet[active_letter_index-1]
    next_letter = alphabet[active_letter_index+1]

    block = '<ol class="pagination actions" role="navigation">'
    # if there is no "previous" page, don't link
    unless active_letter_index == 0
      block << '<li class="previous">'
      block << link_to_letter(previous_letter, '&#8592; '.html_safe + h(ts('Previous')))
      block << '</li>'
    else
      block << '<li class="previous"><span class="disabled">&#8592; ' + h(ts('Previous')) + '</span></li>'
    end

    # Link all the letters
    alphabet.each do |letter|
      unless letter == active_letter
        block << ' <li>' + link_to_letter(letter.upcase) + '</li>'
      else
        block << ' <li><span class="current">' + letter.upcase + '</span></li>'
      end
    end

    unless active_letter_index == (alphabet.size-1)
      block << ' <li class="next">'
      block << link_to_letter(next_letter, h(ts('Next')) + ' &#8594;'.html_safe)
      block << '</li>'
    else
      block << ' <li class="next"><span class="disabled">' + h(ts('Next')) + ' &#8594;</span></li>'
    end

    block << "</ol>"
    block.html_safe
  end
  
  def people_paginated_section(type)
    active_letter = params[:id].upcase
    block = '<div class="pagination">'
    # Link all the letters
    show = case type
      when "Authors"
         '?show=authors'
      when "Reccers"
         '?show=reccers'
      else
         ''
    end
    People.all.each do |character|
      link = "<a href=\"/people/" + character.to_param + show + "\">" + character.char + "</a>"
      unless character.char == active_letter
        block << " " + link
      else
        block << ' <span class="current">' + character.char + '</span>'
      end
    end

    block << "</div>"
    block.html_safe
  end
end
