class Node
  attr_accessor :node_type, :tag_name, :tag_attributes, :children, :contents, :included
  
  BLOCK_TAGS = %w(blockquote center dd div dl dt h1 h2 h3 h4 h5 h6 hr li ol p pre table tbody tfoot thead td tr ul)
  INLINE_TAGS = %w(a b big br caption cite code del em i img q s small span strike strong tt u)
  NO_CHILD_PARAGRAPHS = BLOCK_TAGS - %w(blockquote center div dd dt li td tr)
  SELF_CLOSING_TAGS = %w(br hr img)
  
  def initialize(options={})
    @node_type = options[:node_type]
    @tag_name = options[:tag_name] || ''
    @tag_name.downcase!
    @tag_attributes = options[:tag_attributes] || {}
    @children = options[:children] || []
    @contents = options[:contents] || ''
  end
  
  def block_tag?
    BLOCK_TAGS.include?(self.tag_name)
  end
  
  def block_container_tag?
    ['div', 'blockquote', 'hr', 'center', 'ul', 'ol', 'dl'].include?(self.tag_name)
  end
  
  def inline_tag?
    INLINE_TAGS.include?(self.tag_name)
  end
  
  def allow_child_paragraphs?
    !(self.inline_tag? || NO_CHILD_PARAGRAPHS.include?(self.tag_name))
  end
  
  def paragraph_tag?
    self.tag_name == 'p'
  end
  
  def self_closing?
    SELF_CLOSING_TAGS.include?(self.tag_name)
  end
  
  def text?
    self.node_type == :text
  end
  
  def comment?
    self.node_type == :comment
  end
  
  def self.new_paragraph
    Node.new(:node_type => :html, :tag_name => 'p', :contents => nil)
  end
  
  # Experimenting with adding linebreaks/paragraph tags in this class instead of
  # the html_formatter module. Currently using it to put linebreaks into an inline
  # element's contents without putting them inside a paragraph tag. Because paragraphs
  # inside inline tags inside paragraphs are deeply wrong things.
  def text_to_paragraphs(inline=false)
    nodes = []
    br_node = Node.new(:node_type => :html, :tag_name => 'br', :contents => nil)
    text_paragraphs = self.contents.gsub("\n\n\n+", "\n\n").split("\n\n", -1)
    text_paragraphs.each do |paragraph|
      unless inline
        paragraph_node = Node.new_paragraph
        nodes << paragraph_node
      end
      lines = paragraph.blank? ? [paragraph] : paragraph.split("\n", -1)
      first_line = true
      for line in lines
        unless first_line
          if inline
            nodes << br_node
          else
            paragraph_node.children << br_node
          end
        end
        if line
          if inline
            nodes << Node.new(:node_type => :text, :contents => line)
          else
            paragraph_node.children << Node.new(:node_type => :text, :contents => line)
          end
        end
        first_line = false
      end
    end
    return nodes
  end
  
  # Runs the text_to_paragraphs method on a node's children, recursively
  def add_paragraph_tags_to_children(inline=false)
    nodes = []
    for node in self.children
      if node.text?
        formatted_text_nodes = node.text_to_paragraphs(inline)
        formatted_text_nodes.each {|n| nodes << n}
      else
        node.add_paragraph_tags_to_children(inline)
        nodes << node
      end
    end
    self.children = nodes
  end
  
  # Converts a node (and its children) back into a string
  def render
    if self.node_type == :comment
      "<!--#{self.contents}-->"
    elsif self.node_type == :text
      self.contents
    else
      unless self.tag_name.blank?
        tag = self.tag_name
        attributes = self.tag_attributes.entries.map{|x,y| "#{x}=\"#{y}\""}
        if attributes.empty?
          attributes = ''
        else
          attributes = ' ' + attributes.join(' ') unless attributes.empty?
        end
        if ['hr', 'br', 'img'].include?(tag)
          "<" + tag + attributes + "/>"
        else
          content = self.children.map(&:render).join('')
          "<" + tag + attributes + ">" + content + "</" + tag + ">"
        end
      end
    end
  end
  
end