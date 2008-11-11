require File.dirname(__FILE__) + '/../test_helper'

class MediaControllerTest < ActionController::TestCase
  context "a database with a restricted and an unrestricted work" do
    setup do
      @media = create_media
      @fandom = create_fandom(:media_id => @media.id)
      @work1 = create_work(:fandom_string => @fandom.name)
      @work1.update_attribute(:posted, true)
      @work2 = create_work(:restricted => true, :fandom_string => @fandom.name)
      @work2.update_attribute(:posted, true)
    end
    context "if you are not logged in" do
      setup do
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to :media
      should "show one work" do
        assert_equal [[@fandom, 1]], assigns["fandom_listing"][@media][:fandoms]
      end
      should "not have a more link" do
        assert_equal false, assigns["fandom_listing"][@media][:more]
      end
    end
    context "when logged in" do
      setup do
        @user = create_user
        @request.session[:user] = @user 
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to :media, :equal => [@media]
      should "show two works" do
        assert_equal [[@fandom, 2]], assigns["fandom_listing"][@media][:fandoms]
      end
    end
    context "and five more fandoms" do
      setup do
        for i in 0...5 do 
          fandom = create_fandom(:media_id => @media.id)
        end
        get :index, :locale => 'en'
      end
      should "have a more link" do
        assert_equal true, assigns["fandom_listing"][@media][:more]
      end      
    end
  end
end
