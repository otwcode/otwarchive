# def graph_data(item, relationship)
#   must_have_sparklines!
#   if block_given?
#     return yield(item, relationship)
#   else
#     case @options[:type].to_sym
#     when :pie
#       return [(item.send(relationship.name).size.to_f/relationship.klass.count.to_f)*100]
#     else
#       return [0]
#     end
#   end
# end

require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/view/show_views'

include Streamlined::View::ShowViews
describe "Streamlined::View::Graph" do
   
   def pretend_sparklines
     flexmock(Graph).new_instances.should_receive(:must_have_sparklines!).and_return(true)
     @graph = Graph.new(:type=>:pie)  
   end
   
   it "graph data with block" do
     pretend_sparklines
     assert_equal :block_result, @graph.graph_data(:anything, :anything) {:block_result}
   end
   
   it "graph data with pie" do
     pretend_sparklines
     item = flexmock(:widgets=>flexmock(:size=>10))
     rel = flexmock(:name=>:widgets, :klass=>flexmock(:count=>20)) 
     assert_equal [50.0], @graph.graph_data(item, rel)
   end   
    
   it "graph data with invalid type" do
     pretend_sparklines
     @graph.graph_options[:type] = :invalid_type
     assert_equal [0], @graph.graph_data(nil, nil)
   end                                            
                            
   # this is gross - the branch chosen is environment dependent
   it "must have sparklines" do
     @graph = Graph.new
     if 'Sparklines'.to_const
       assert_nothing_raised {@graph.must_have_sparklines!}
     else
       assert_raise(RuntimeError) {@graph.must_have_sparklines!}
     end
   end

end
