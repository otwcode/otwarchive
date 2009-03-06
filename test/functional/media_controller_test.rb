require File.dirname(__FILE__) + '/../test_helper'

class MediaControllerTest < ActionController::TestCase

  context "a media with canoncal and non-canonical fandoms" do
    setup do
      @media = create_media(:canonical => true)
      @fandom1 = create_fandom(:media_id => @media.id)
      @fandom2 = create_fandom(:canonical => true, :media_id => @media.id)
    end
    context "on get" do
      setup {get :index, :locale => 'en'}
      should_render_template :index
      should "only include the canonical fandom in the fandom_listing" do
        assert_contains(assigns(:fandom_listing), [@media, [@fandom2]])
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
        end
      end
      context "on get" do
        setup {get :index, :locale => 'en'}
        should "have a more link" do
          assert_tag :tag => 'a', :content => /All .*\.\.\./
        end
      end
      context "on list" do
        setup { get :show, :locale => 'en', :id => @media.name }
        should_assign_to(:fandoms) {@media.fandoms.canonical.by_name}
        should "list six fandoms" do
          assert_equal 6, assigns(:fandoms).size
        end
      end
    end
  end
end
