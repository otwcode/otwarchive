module Tolk
  class LinkRenderer < WillPaginate::LinkRenderer
    def to_html
      links = @options[:page_links] ? windowed_links : []
      # previous/next buttons
      links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
      links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])
      
      html = links.join(@options[:separator])
      @options[:container] ? @template.content_tag(:div, safe_string(html), html_attributes) : safe_string(html)
    end

    protected

    def page_link(page, text, attributes = {})
      @template.link_to safe_string(text), url_for(page), attributes
    end

    def page_span(page, text, attributes = {})
      @template.content_tag :span, safe_string(text), attributes
    end

    def safe_string(string)
      string.respond_to?(:html_safe) ? string.html_safe : string.html_safe!
    end

  end
end
