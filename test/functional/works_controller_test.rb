require File.dirname(__FILE__) + '/../test_helper'

# TODO error checking
# TODO work as admin
class WorksControllerTest < ActionController::TestCase

  context "if you are not logged in" do
    setup do
      @work = create_work
    end
    context "when browsing works" do
      setup do
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to :works
    end
    context "works that aren't posted" do
      setup do
        get :show, :locale => 'en', :id => @work.id
      end
      should_respond_with 403
    end
    context "works which are posted" do
      setup do
        @work.update_attribute("posted", true)
        get :show, :locale => 'en', :id => @work.id
      end
      should_render_template :show
      should_assign_to :work
    end
    context "works that are adult" do
      setup do
        @work.update_attribute("posted", true)
        @tag = create_tag(:adult => true)
        @work.update_attribute('default', @tag.name)
        get :show, :locale => 'en', :id => @work.id
      end
      should_render_template :adult
    end
    context "when creating a work" do
      setup do
        get :new, :locale => 'en', 
            :work => { :title => 'New work title', 
            :chapter_attributes => {:content => 'Stuff in new chapter'}}
        end
      should_redirect_to 'new_session_url(:restricted => true)'
    end
    context "when destroying a work" do
      setup do
        delete :destroy, :locale => 'en', :id => @work.id
      end
      should "not destroy the record" do
        assert @work.reload
      end
    end
    context "when updating a work" do
      setup do
        put :update, :locale => 'en', :id => @work.id, 
            :work => { :title => "New Title", 
                   :chapter_attributes => {:content => "New Content"}}
      end
      should "not update the record" do
        assert_not_equal "New Title", @work.title
        assert_not_equal "New Content", @work.chapters.first.content
      end
    end
  end
  
  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user 
    end
    context "when creating a work" do
      setup do
        get :new, :locale => 'en'
      end
      should_assign_to :work
      should_render_template :new
    end

    context "when working with your own work" do
      setup do
        @work = create_work(:authors => [@user.default_pseud])
      end
      context "works that are adult" do
        setup do
          @work.update_attribute("posted", true)
          @tag = create_tag(:adult => true)
          @work.update_attribute('default', @tag.name)
          get :show, :locale => 'en', :id => @work.id
        end
        should_render_template :show
        should_assign_to :work
      end
      context "when browsing works" do
        setup do
          get :index, :locale => 'en'
        end
        should_render_template :index
        should_assign_to :works
      end
      context "works that aren't posted" do
        setup do
          @work.update_attribute("posted", true)
          get :show, :locale => 'en', :id => @work.id
        end
        should_render_template :show
        should_assign_to :work
      end
      context "when editing a work" do
        setup do
          get :edit, :locale => 'en', :id => @work.id
        end
        should_render_template :edit
        should_assign_to :work
      end
      context "when updating a work" do
        setup do
          put :update, :locale => 'en', :id => @work.id, 
              :work => { :title => "New Title", 
                     :chapter_attributes => {:content => "New Content"}}
          @work.reload
        end
        should "update the record" do
          assert_equal "New Title", @work.title
          assert_equal "New Content", @work.chapters.first.content
        end
      end
      context "when destroying a work" do
        setup do
          delete :destroy, :locale => 'en', :id => @work.id
        end
        should "destroy the record" do
          assert_raises(ActiveRecord::RecordNotFound) { @work.reload }
        end
      end
    end

    context "when working with someone else's work" do
      setup do
        @work = create_work
      end
      context "when browsing works" do
        setup do
          get :index, :locale => 'en'
        end
        should_render_template :index
        should_assign_to :works
      end
      context "works that aren't posted" do
        setup do
          get :show, :locale => 'en', :id => @work.id
        end
        should_respond_with 403
      end
      context "works which are posted" do
        setup do
          @work.update_attribute("posted", true)
          get :show, :locale => 'en', :id => @work.id
        end
        should_render_template :show
        should_assign_to :work
      end
      context "works that are adult" do
        setup do
          @work.update_attribute("posted", true)
          @tag = create_tag(:adult => true)
          @work.update_attribute('default', @tag.name)
          get :show, :locale => 'en', :id => @work.id
        end
        should_render_template :adult
      end
      context "if you set your preference, works that are adult" do
        setup do
          @user.preference.update_attribute("adult", true)
          @request.session[:user] = @user 
          @work.update_attribute("posted", true)
          @tag = create_tag(:adult => true)
          @work.update_attribute('default', @tag.name)
          get :show, :locale => 'en', :id => @work.id
        end
        should_render_template :show
      end
      context "when editing a work" do
        setup do
          get :edit, :locale => 'en', :id => @work.id
        end
        should_redirect_to 'work_path(@work)'
        should_set_the_flash_to /have permission/      
      end
      context "when updating a work" do
        setup do
          put :update, :locale => 'en', :id => @work.id, 
              :work => { :title => "New Title", 
                     :chapter_attributes => {:content => "New Content"}}
        end
        should "not update the record" do
          assert_not_equal "New Title", @work.title
          assert_not_equal "New Content", @work.chapters.first.content
        end
      end
      context "when destroying a work" do
        setup do
          delete :destroy, :locale => 'en', :id => @work.id
        end
        should_redirect_to 'work_path(@work)'
        should "not destroy the record" do
          assert @work.reload
        end
        should_set_the_flash_to /have permission/      
      end
    end
  end
    
end
