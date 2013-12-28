require 'test_helper'

class RedirectControllerTest < ActionController::TestCase

  context "on GET to :index" do
    setup do
      get :index
    end
    should "display a form" do
      assert_select "form", true
    end    
  end
  
  context "on POST to :show" do
    context "without a url" do
      setup do
        get :show
      end
      should_set_the_flash_to /What url/
      should_redirect_to("index") {'redirect'}
    end
    
    context "with a url not in the archive" do
      setup do
        @url = "http://adfsadf.com"
        get :show, :original_url => @url
      end
      should_set_the_flash_to /could not find a work/
      should_redirect_to("index") {'redirect'}
    end

    context "with a url in the archive" do 
      setup do
        storyparser = StoryParser.new
        @url = "http://www.intimations.org/fanfic/davidcook/Madrigals%20and%20Misadventures.html"
        @work = storyparser.download_and_parse_story(@url, :pseuds => [create_pseud], :post_without_preview => true, :do_not_set_current_author => true)
        @work.save
        get :show, :original_url => @url
      end
      should_redirect_to("work") {work_path(@work)}
    end
  end

end
