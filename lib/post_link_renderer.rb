# frozen_string_literal: true

class PostLinkRenderer < PaginationListLinkRenderer
  def previous_or_next_page(page, text, classname, remote = nil)
    if page
      submit(text, page, classname, class: classname)
    else
      super
    end
  end

  def page_number(page, remote = nil)
    unless page == current_page
      submit(page, page, nil)
    else
      super
    end
  end

  def submit(text, target, target_name, attributes = {})
    string_attributes = attributes.inject(+'') do |attrs, pair|
      unless pair.last.nil?
        attrs << %( #{pair.first}="#{CGI.escapeHTML(pair.last.to_s)}")
      end
      attrs
    end

    if target_name.nil?
      %(<input#{string_attributes} type="submit" name="page" value="#{text}">)
    else
      %(<input type="hidden" name="#{target_name}_value" value="#{target}">) +
        %(<input#{string_attributes} type="submit" name="#{target_name}" value="#{text}">)
    end
  end
end
