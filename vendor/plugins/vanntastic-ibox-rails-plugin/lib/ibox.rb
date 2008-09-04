module Innerfusion
  module Ibox
    IMAGE_EXTENSIONS = ["jpg","gif","png","jpeg","png"]
    FILE_EXTENSIONS = ["html","htm","cfm","asp","php","rb","rhtml","txt"]
    REQUEST_TYPES = {
      :image => 1,
      :inline => 2,
      :ajax => 3
    }
  
   # TODO : complete the functional test 
   # link_to_ibox creates a ibox_link
   # USAGE : 
   # Link an ibox to a picture:
   #    link_to_ibox "View Image", :for => "my/special/image.jpg"
   # Link an ibox to a page to load via ajax
   #    link_to_ibox "View Page", :for => "my/special/page"
   # Link to an ibox and specify the size (WxH), this defaults to :auto 
   #    link_to_ibox "View Page", :for => "my/special/image.jpg", :size => "300x300"
   # OPTIONS :
   #     * content => the content of the link
   #     * :for => the content that you want to put in the ibox, it can be an image, page or inline content
   #     - :size => the width and height of the ibox, it will default to :auto
   #     - :title => This is the title attribute of the link tag
   #     - :type => This is the type of ibox you want, link_to_ibox will try to detect it based on the :for argument 
   #     you can add in extra options for the tag as needed
   def link_to_ibox(content="",options = {})
     options[:for] ||= ""
     options[:size] ||= :auto
     options[:title] ||= options[:for]
     options[:type] ||= determine_file_type(options[:for])
     
     width, height = options[:size].split("x")[0], options[:size].split("x")[1] unless options[:size].is_a?(Symbol)
     rel = options[:size] == :auto ? "ibox&type=#{REQUEST_TYPES[options[:type]]}" : "ibox&width=#{width}&height=#{height}&type=#{REQUEST_TYPES[options[:type]]}"
     
     keys_to_remove = [:for,:size,:type]
     html_options = {}
     options.each {|key,value| html_options.update(key => value) unless keys_to_remove.include?(key)}
     html_options.update(:rel => rel)
     
     link_to content, (options[:for]), html_options
   end 
   
   # add this in your layout file which will add in the necessary files that you need for ibox
   def iboxify_page
     content = stylesheet_link_tag("ibox/ibox")
     content << "\n#{javascript_include_tag('ibox/ibox')}"
     content
   end
   
   def determine_file_type(type)
     request_type = type.split(".").last
     return :image if IMAGE_EXTENSIONS.include?(request_type)
     return :ajax if FILE_EXTENSIONS.include?(request_type) || type.first != "#"
     return :inline
   end
  end
end