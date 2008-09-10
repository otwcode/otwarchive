module HomeHelper
  def html_to_text(string)
    string.gsub!(/<br\s*\/?>/, "\n")
    string.gsub!(/<\/?p>/, "\n\n")
    string = strip_tags(string)
    string.gsub!(/^[ \t]*/, "")
    while !string.gsub!(/\n\n\n/, "\n\n").nil?
      # keep going
    end
    return string
  end
  
  def link_to_passwd
    link_to_function(h("Return to standard login").t, :href => url_for(:action => 'index', :use_openid => false), :class => 'footnote') do |page|
            page.replace_html "switch_fields", :partial => 'passwd'
            page[:link_to_passwd].hide
            page[:link_to_openid].show
            end
  end
 
  def link_to_openid
    link_to_function(h("Login with OpenID").t, :href => url_for(:action => 'index', :use_openid => true), :class => 'footnote') do |page|
            page.replace_html "switch_fields", :partial => 'openid'
            page[:link_to_openid].hide
            page[:link_to_passwd].show
            end
  end
  
end
