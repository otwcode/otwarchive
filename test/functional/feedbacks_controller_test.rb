require File.dirname(__FILE__) + '/../test_helper'

class FeedbacksControllerTest < ActionController::TestCase

  context "on GET to :new" do
    setup do
      get :new, :locale => 'en'
    end
    should_assign_to :feedback
    should_respond_with :success
    should_render_template :new
  end

  context "on POST to :create" do
    context "on failure" do
      setup do
        put :create, :locale => 'en', :feedback => {:comment=>""}
      end
      should_assign_to :feedback
      should_render_template :new
      should "show validation errors" do
        assert_tag :tag => "div", :attributes => {:id => "errorExplanation"}
      end
    end

    context "on success" do
      setup do
        put :create, :locale => 'en', :feedback => {:comment=>"a comment"}
      end
      should_set_the_flash_to /thanks/
      should_redirect_to '"/"'
    end

  end
end


