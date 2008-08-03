require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe Author do
  describe "(newly created)" do
    before do
      @category = Category.create!
      @other_category = Category.create!
      @author = Author.create!
    end
  
    it "#posts should == []" do
      @author.posts.should == []
    end
   
    it "#categories should == []" do
      @author.categories.should == []
    end
  
    it "#similar_posts should == []" do
      @author.similar_posts.should == []
    end
  
    it "#similar_authors should == []" do
      @author.similar_authors.should == []
    end
  
    it "#commenters should == []" do
      @author.commenters.should == []
    end
  
    describe "who creates post with category" do
      before do
        @post = Post.create! :author => @author, :category => @category
      end
  
      it "#posts should == [post]" do
        @author.posts.should == [@post]
      end
    
      it "#categories should == [category]" do
        @author.categories.should == [@category]
      end
    
      describe "and @other_author creates post2 in category" do
      
        before do
          @other_author = Author.create!
          @post2 = Post.create! :author => @other_author, :category => @category
        end
    
        it "#posts should == [post2]" do
          @author.posts.should == [@post]
        end

        it "#categories should == [category]" do
          @author.categories.should == [@category]
        end

        it "#similar_posts.should == [post, post2]" do
          @author.similar_posts.should == [@post, @post2]
        end
      
        it "#similar_authors.should == [@author, @other_author]" do
          @author.similar_authors.should == [@author, @other_author]
        end
        
        describe "and creates @other_post in @other_category" do
          before do
            @other_category = Category.create!
            @other_post = Post.create! :author => @other_author, :category => @other_category
          end
          
          it "#similar_posts.should == [@post, @post2]" do
            @author.similar_posts.should == [@post, @post2]
          end
          
          it "#posts_by_similar_authors.should == [@post, @post2, @other_post]" do
            @author.posts_of_similar_authors.should == [@post, @post2, @other_post]
          end
        end
      end
    end
  end
end