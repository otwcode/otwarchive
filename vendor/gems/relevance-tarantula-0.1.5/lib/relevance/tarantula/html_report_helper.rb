require "erb"
module Relevance::Tarantula::HtmlReportHelper 
  include ERB::Util
  include Relevance::Tarantula
  def wrap_in_line_number_table_row(text, &blk)
    x = Builder::XmlMarkup.new

    x.tr do
      lines = text.split("\n")
      x.td(:class => "numbers") do
        lines.size.times do |index|
          x.span(index+1, :class => "line number")
        end
      end
      x.td(:class => "lines") do
        lines.each do |line|
          x.span(line, :class => "line")
        end
      end
    end

    x.target!
  end 
                                                                            
  def textmate_url(file, line_no)
    "txmt://open?url=file://#{File.expand_path(File.join(rails_root,file))}&line_no=#{line_no}"
  end
  
  def wrap_stack_trace_line(text)
    if text =~ %r{^\s*(/[^:]+):(\d+):([^:]+)$}
      file = h($1) # .to_s_xss_protected
      line_number = $2
      message = h($3) # .to_s_xss_protected
      "<a href='#{textmate_url(file, line_number)}'>#{file}:#{line_number}</a>:#{message}" # .mark_as_xss_protected
    else
      h(text) # .to_s_xss_protected
    end
  end
end
