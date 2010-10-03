require 'test_helper'

class FandomsControllerTest < ActionController::TestCase

  context "a media with canonical and non-canonical fandoms" do
    setup do
      @medium = create_media(:canonical => true)
      @fandom1 = create_fandom
      @fandom2 = create_fandom(:canonical => true)
      @fandom_without_works = create_fandom(:canonical => true)
      @fandom1.add_association(@medium)
      @fandom2.add_association(@medium)
      @fandom_without_works.add_association(@medium)
      @fandom_with_other_media = create_fandom(:canonical => true)
      fandom_string = [@fandom1.name, @fandom2.name, @fandom_with_other_media.name].join(', ')
      @work = create_work(:posted => true, :fandom_string => fandom_string)
    end
    context "on index for that media" do
      setup { get :index, :medium_id => @medium.name }
      should_render_template :index
      should "produce an array of fandom tags which includes the canonical fandom" do
        assert assigns(:fandoms).include? @fandom2
      end
      should "only display canonical fandoms" do
        assert_does_not_contain assigns(:fandoms), @fandom
      end
      should "only display fandoms with works" do
        assert_does_not_contain assigns(:fandoms), @fandom_without_works
      end
      should "only display fandoms belonging to the specified medium" do
        assert_does_not_contain assigns(:fandoms), @fandom_with_other_media
      end            
    end
  end
end