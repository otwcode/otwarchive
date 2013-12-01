require 'spec_helper'

describe Skin do

  describe "save" do
    
    before(:each) do
      @child_skin = Skin.new(:title => "Child", :css => "body {background: #fff;}")
      @parent_skin = Skin.new(:title => "Parent", :css => "body {color: #000;}")
      @child_skin.save; @parent_skin.save
      @skin_parent = SkinParent.new(:child_skin => @child_skin, :parent_skin => @parent_skin, :position => 1)
    end

    it "should save a basic parent relationship" do
      @skin_parent.save.should be_true
    end
    
    it "should require a position to save" do
      @skin_parent.position = nil
      @skin_parent.save.should_not be_true
      @skin_parent.errors[:position].should_not be_empty
    end

    it "should not allow using a site skin as parent for a skin unless it has role override" do
      @parent_skin.role = "site"
      @parent_skin.save
      @skin_parent.save.should_not be_true
      @skin_parent.errors[:base].should_not be_empty
      @child_skin.role = "override"
      @child_skin.save
      @skin_parent.save.should be_true
    end

    it "should not allow a duplicate parent-child relationship" do
      @skin_parent.save
      skin_parent2 = SkinParent.new(:child_skin => @child_skin, :parent_skin => @parent_skin, :position => 2)
      skin_parent2.save.should_not be_true
      skin_parent2.errors[:base].should_not be_empty      
    end
    
    it "should not allow a skin to be its own parent" do
      @skin_parent.parent_skin = @child_skin
      @skin_parent.save.should_not be_true
    end
    
    it "should not allow a skin ancestry with an infinite loop in it" do
      @skin_parent.save.should be_true

      # first invalid one: parent shouldn't be allowed to have child as parent
      own_grandparent = SkinParent.new(:child_skin => @parent_skin, :parent_skin => @child_skin, :position => 1)
      own_grandparent.save.should_not be_true
      own_grandparent.errors[:base].should_not be_empty

      grandchild_skin = Skin.new(:title => "Grandchild", :css => "body {color: red;}")
      grandchild_skin.save.should be_true
      skin_parent2 = SkinParent.new(:child_skin => grandchild_skin, :parent_skin => @child_skin, :position => 1)
      skin_parent2.save.should be_true

      # grandchild shouldn't be allowed to have grandparent 
      duplicate_ancestor = SkinParent.new(:child_skin => grandchild_skin, :parent_skin => @parent_skin, :position => 2)
      duplicate_ancestor.save.should_not be_true
      duplicate_ancestor.errors[:base].should_not be_empty
    end

  end

end
