require File.dirname(__FILE__) + '/../test_helper'

class MediaControllerTest < ActionController::TestCase

  context "a media with non-canonical fandoms" do
    setup do
      @media = create_media(:canonical => true)
      @fandom1 = create_fandom(:media_id => @media.id)
      get :index, :locale => 'en'
    end
    should_render_template :index
    should_assign_to :fandom_listing, :equal => []
    context "a database and canonical fandoms" do
      setup do
        @fandom2 = create_fandom(:canonical => true, :media_id => @media.id)
      end
      should_assign_to :fandom_listing, :equal => [[@media, [@fandom2]]]
      context "and five more fandoms" do
        setup do
          for i in 0...5 do 
            fandom = create_fandom(:canonical => true, :media_id => @media.id)
          end
          get :index, :locale => 'en'
        end
        should "have a more link" do
          assert_tag :tag => 'a', :content => /All .*\.\.\./
        end
        context "when listed" do
          setup { get :show, :locale => 'en', :id => @media.name }
          should_assign_to :fandoms, :equal => 'Fandom.find(:all, :media_id => @media.id)'
        end
      end      
    end
  end
end
