require 'spec_helper'

describe Skin do

  describe "save" do

    before(:each) do
      @child_skin = Skin.new(title: "Child", css: "body {background: #fff;}")
      @parent_skin = Skin.new(title: "Parent", css: "body {color: #000;}")
      @child_skin.save; @parent_skin.save
      @skin_parent = SkinParent.new(child_skin: @child_skin, parent_skin: @parent_skin, position: 1)
    end

    it "should save a basic parent relationship" do
      expect(@skin_parent.save).to be_truthy
    end

    it "should require a position to save" do
      @skin_parent.position = nil
      expect(@skin_parent.save).not_to be_truthy
      expect(@skin_parent.errors[:position]).not_to be_empty
    end

    it "should not allow using a site skin as parent for a skin unless it has role override" do
      @parent_skin.role = "site"
      @parent_skin.save
      expect(@skin_parent.save).not_to be_truthy
      expect(@skin_parent.errors[:base]).not_to be_empty
      @child_skin.role = "override"
      @child_skin.save
      expect(@skin_parent.save).to be_truthy
    end

    it "should not allow a duplicate parent-child relationship" do
      @skin_parent.save
      skin_parent2 = SkinParent.new(child_skin: @child_skin, parent_skin: @parent_skin, position: 2)
      expect(skin_parent2.save).not_to be_truthy
      expect(skin_parent2.errors[:base]).not_to be_empty
    end

    it "should not allow a skin to be its own parent" do
      @skin_parent.parent_skin = @child_skin
      expect(@skin_parent.save).not_to be_truthy
    end

    it "should not allow a skin ancestry with an infinite loop in it" do
      expect(@skin_parent.save).to be_truthy

      # first invalid one: parent shouldn't be allowed to have child as parent
      own_grandparent = SkinParent.new(child_skin: @parent_skin, parent_skin: @child_skin, position: 1)
      expect(own_grandparent.save).not_to be_truthy
      expect(own_grandparent.errors[:base]).not_to be_empty

      grandchild_skin = Skin.new(title: "Grandchild", css: "body {color: red;}")
      expect(grandchild_skin.save).to be_truthy
      skin_parent2 = SkinParent.new(child_skin: grandchild_skin, parent_skin: @child_skin, position: 1)
      expect(skin_parent2.save).to be_truthy

      # grandchild shouldn't be allowed to have grandparent
      duplicate_ancestor = SkinParent.new(child_skin: grandchild_skin, parent_skin: @parent_skin, position: 2)
      expect(duplicate_ancestor.save).not_to be_truthy
      expect(duplicate_ancestor.errors[:base]).not_to be_empty
    end

    it "should not allow a parent to be blank" do
      expect(@child_skin.save).to be_truthy
      blank_parent = Skin.new(title: " ", css: "body {color: #000;}")
      blank_parent_child = SkinParent.new(child_skin: @child_skin, parent_skin: blank_parent, position: 1)
      expect(blank_parent_child.save).to be_truthy
      expect(blank_parent_child.parent_skin_id).to be(nil)
    end

  end

end
