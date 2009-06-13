require File.dirname(__FILE__) + '/../test_helper'

class MediaControllerTest < ActionController::TestCase

  context "a media with canonical and non-canonical fandoms" do
    setup do
      @media = create_media(:canonical => true)
      @fandom1 = create_fandom(:media_id => @media.id)
      @fandom2 = create_fandom(:canonical => true, :media_id => @media.id)
      fandom_string = [@fandom1.name, @fandom2.name].join(', ')
      @work = create_work(:posted => true, :fandom_string => fandom_string)
    end
    context "on get" do
      setup {get :index}
      should_render_template :index
      should "produce an array of media tags" do
        assert assigns(:media).include? @media
      end
      should "only include the canonical fandom in the fandom_listing" do
        assert_contains assigns(:fandom_listing)[@media], @fandom2
      end
    end
    context "on list" do
      setup { get :show, :locale => 'en', :id => @media.name }
      should "include canonical fandom" do
        assert_contains(assigns(:fandoms), @fandom2)
      end
      should "not include non canonical fandom" do
        assert_does_not_contain(assigns(:fandoms), @fandom1)
      end
    end
    context "and five more canonical fandoms" do
      setup do
        for i in 0...5 do
          fandom = create_fandom(:canonical => true, :media_id => @media.id)
          @work.fandoms << fandom
        end
      end
      context "on get" do
        setup {get :index, :locale => 'en'}
        should "have a more link" do
          assert_tag :tag => 'a', :content => /All .*\.\.\./
        end
      end
    end
    context "that start with the letter f" do
      setup do
        @media = create_media(:canonical => true)
        @fandom1 = create_fandom(:canonical => true, :media_id => @media.id, :name => "Farscape")
        @fandom2 = create_fandom(:canonical => true, :media_id => @media.id, :name => "Firefly") 
        @work = create_work(:posted => true, :fandom_string => "Farscape")
        @invisible_work = create_work(:fandom_string => "Firefly")
      end
      context "on list" do
        setup { get :show, :id => @media.name, :letter => 'F' }
        should_assign_to :fandoms
        should "include canonical fandoms with visible works" do
          assert_contains(assigns(:fandoms), @fandom1)
        end
        should "not include fandoms without visible works" do
          assert_does_not_contain(assigns(:fandoms), @fandom2)  
        end
      end    
    end
  end
end
