require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe 'Commenter use case (a1: p1>c1, a2: p2>c1, p3>c2, a3: p4>c3)' do
  before do
    @c1 = Category.create!
    @c2 = Category.create!
    @c3 = Category.create!
    @a1 = Author.create!
    @a2 = Author.create!
    @a3 = Author.create!
    @p1 = @a1.posts.create! :category => @c1
    @p2 = @a2.posts.create! :category => @c1
    @p3 = @a2.posts.create! :category => @c2
    @p4 = @a3.posts.create! :category => @c3
    @a1.reload
    @a2.reload
  end

  it "a1.posts should == [p1]" do
    @a1.posts.should == [@p1]
  end

  it "a1.categories should == [c1]" do
    @a1.categories.should == [@c1]
  end
  
  it "a2.posts should == [p2, p3]" do
    @a2.posts.should == [@p2, @p3]
  end

  it "a2.categories should == [c1, c2]" do
    @a2.categories.should == [@c1, @c2]
  end
  
  describe "u1 comments on p2" do
    before do
      @u1 = User.create!
      @comment = @p2.comments.create! :user => @u1
    end
    
    it "u1.comments should == [comment]" do
      @u1.comments.should == [@comment]
    end
    
    it "a1.commenters should be empty" do
      @a1.commenters.should be_empty
    end
    
    it "a2.commenters should == [u1]" do
      @a2.commenters.should == [@u1]
    end
    
    it "u1.commented_posts should == [p2]" do
      @u1.commented_posts.should == [@p2]
    end
    
    it "u1.commented_posts.find_inflamatory(:all) should be empty" do
      @u1.commented_posts.find_inflamatory(:all).should be_empty
    end
    
    if ActiveRecord::Base.respond_to?(:named_scope)
      it "u1.commented_posts.inflamatory should be empty" do
        @u1.commented_posts.inflamatory.should be_empty
      end
    end
    
    it "u1.commented_authors should == [a2]" do
      @u1.commented_authors.should == [@a2]
    end
    
    it "u1.posts_of_interest should == [p1, p2, p3]" do
      @u1.posts_of_interest.should == [@p1, @p2, @p3]
    end
    
    it "u1.categories_of_interest should == [c1, c2]" do
      @u1.categories_of_interest.should == [@c1, @c2]
    end
    
    describe "when p2 is inflamatory" do
      before do
        @p2.toggle!(:inflamatory)
      end
      
      it "p2 should be inflamatory" do
        @p2.should be_inflamatory
      end
      
      it "u1.commented_posts.find_inflamatory(:all) should == [p2]" do
        # uniq ids is here (and next spec) because eager loading changed behaviour 2.0.2 => edge
        @u1.commented_posts.find_inflamatory(:all).collect(&:id).uniq.should == [@p2.id]
      end
        
      it "u1.posts_of_interest.find_inflamatory(:all).uniq should == [p2]" do
        @u1.posts_of_interest.find_inflamatory(:all).collect(&:id).uniq.should == [@p2.id]
      end
      
      if ActiveRecord::Base.respond_to?(:named_scope)
        it "u1.commented_posts.inflamatory should == [p2]" do
          @u1.commented_posts.inflamatory.should == [@p2]
        end

        it "u1.posts_of_interest.inflamatory should == [p2]" do
          @u1.posts_of_interest.inflamatory.should == [@p2]
        end
      end
    end
  end
end
