module FormTestHelper

  module LinkMethods
    def select_link(text=nil)
      @html_document = nil # So it always grabs the latest response
      links = if text.nil?
        select_first_link
      elsif css_select(%|a[href="#{text}"]|).any?
        select_link_by_href(text)
      else
        select_link_by_text(text)
      end
      decorate_link(links.first)
    end
  
    def decorate_link(link)
      link.extend FormTestHelper::Link
      link.testcase = self
      link
    end
    
    private
    
    def select_first_link
      assert_select('a', 1)
    end
    
    def select_link_by_href(text)
      assert_select("a[href=?]", text)
    end
    
    def select_link_by_text(text)
      assert_select('a', text)
    end
    
  end
  
end