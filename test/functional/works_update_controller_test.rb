require 'test_helper'

# FIXME needs many more tests
class WorksUpdateControllerTest < ActionController::TestCase
  tests WorksController

  context "if you are not logged in" do
    setup do
      @work = create_work
      @work.add_default_tags
      put :update, :locale => 'en', :id => @work.id
    end
    should_redirect_to("the work's path") {work_path(@work)}
    should_set_the_flash_to /have permission/
  end

  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
      @title = random_phrase
      @content = random_paragraph
      @fandom = random_phrase
      @chapter_attribs = {"title"=>"", "content"=>@content}
      @author_attribs = {"ids"=>[@user.default_pseud.id]}
      @rating = "Not Rated"
      @warning = ["Choose Not To Use Archive Warnings"]
    end

    context "when working with someone else's work" do
      setup do
        new_user = create_user
        @work = create_work(:authors => [new_user.default_pseud])
        @work.add_default_tags
        put :update, :locale => 'en', :id => @work.id
      end
      should_redirect_to("the work's path") {work_path(@work)}
      should_set_the_flash_to /have permission/
    end

    context "when working with your own work" do
      setup do
        @work = create_work(:authors => [@user.default_pseud])
        @work.add_default_tags
        put :update, :locale => 'en', :id => @work.id, :work => {:title => "new title"}
      end
      should_redirect_to("the work's path") {work_path(@work)}
      should "update title" do
        assert_equal "new title", Work.find(@work.id).title
      end
    end

    context "when editing your own work in a collection" do
      setup do
        @collection = create_collection
        @work = create_work(:authors => [@user.default_pseud])
        @work.add_default_tags
        @work.add_to_collection(@collection)
        @work.save
        put :update, :locale => 'en', :id => @work.id, :preview_button => "Preview", :work => {"chapter_attributes"=>@chapter_attribs, 
                "author_attributes"=>@author_attribs, "title"=>@title, "fandom_string"=>@fandom, 
                "rating_string"=>@rating, "warning_strings"=>@warning, "wip_length"=>"1", 
                :collection_names => @collection.name}
      end
      should_respond_with :success
      should_render_template :preview
      should_assign_to :work
      should_eventually "keep the work in the collection" do
        assert @collection.works.include?(assigns(:work))
        assert @collection.approved_works.include?(assigns(:work))
        assert assigns(:work).approved_collections.include?(@collection)
      end
    end
    
  end

  
end
