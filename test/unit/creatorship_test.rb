require 'test_helper'

class CreatorshipTest < ActiveSupport::TestCase
  context "A Creatorship" do
    should_belong_to :pseud, :creation
    
    context "on orphaning" do
      setup do 
        @user = create_user
        @chapter = new_chapter(:authors=>[@user.default_pseud])
        @work = create_work(:authors => [@user.default_pseud], :chapters => [@chapter])
        Creatorship.orphan([@user.default_pseud], [@work])
        @work.reload
      end
      should "orphan the work" do
        assert_equal [User.orphan_account.default_pseud], @work.pseuds
      end
    end
    context "on orphaning with same name" do
      setup do 
        @user = create_user
        @chapter = new_chapter(:authors=>[@user.default_pseud])
        @work = create_work(:authors => [@user.default_pseud], :chapters => [@chapter])
        Creatorship.orphan([@user.default_pseud], [@work], false)
        @work.reload
      end
      should "orphan the work" do
        assert_equal [User.orphan_account.pseuds.last], @work.pseuds
      end
    end
  end
end
