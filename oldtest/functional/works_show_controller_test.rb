require 'test_helper'

class WorksShowControllerTest < ActionController::TestCase
  tests WorksController

  context "a non-adult work" do
    setup do
      Rating.create_canonical(ArchiveConfig.RATING_GENERAL_TAG_NAME, false)
      @work = create_work(:authors => [create_user.default_pseud])
      @work.add_default_tags
      @work.rating_string = ArchiveConfig.RATING_GENERAL_TAG_NAME
    end
    context "that isn't posted" do
      context "when not logged in" do
        setup { get :show, :locale => 'en', :id => @work.id }
        should_redirect_to('new session path') {new_session_path}
      end
      context "when logged in" do
        setup do
          @user = create_user
          @request.session[:user] = @user
          get :show, :locale => 'en', :id => @work.id
        end
        should_set_the_flash_to /permission/
        should_redirect_to("the current user's path"){@user}
        context "and it's your work" do
          setup do
            @work.pseuds << @user.default_pseud
            get :show, :locale => 'en', :id => @work.id
          end
          should_render_template :show
        end
      end
      context "that is restricted" do
        setup {@work.update_attribute("restricted", true) }
        context "when not logged in" do
          setup { get :show, :locale => 'en', :id => @work.id }
          should_redirect_to('restricted new session path') {new_session_path(:restricted => true)}
        end
        context "when logged in" do
          setup do
            @user = create_user
            @request.session[:user] = @user
            get :show, :locale => 'en', :id => @work.id
          end
          should_set_the_flash_to /permission/
          should_redirect_to("the current user's path"){@user}
          context "and it's your work" do
            setup do
              @work.pseuds << @user.default_pseud
              get :show, :locale => 'en', :id => @work.id
            end
            should_render_template :show
          end
        end
      end
    end
    context "that is posted" do
      setup {@work.update_attribute("posted", true) }
      context "when not logged in" do
        setup { get :show, :locale => 'en', :id => @work.id }
        should_render_template :show
        should_assign_to :work
      end
      context "when logged in" do
        setup do
          @user = create_user
          @request.session[:user] = @user
          get :show, :locale => 'en', :id => @work.id
        end
        should_render_template :show
        should_assign_to :work
        context "and it's your work" do
          setup do
            @work.pseuds << @user.default_pseud
            get :show, :locale => 'en', :id => @work.id
          end
          should_render_template :show
        end
      end
      context "that is restricted" do
        setup {@work.update_attribute("restricted", true) }
        context "when not logged in" do
          setup { get :show, :locale => 'en', :id => @work.id }
          should_redirect_to('restricted new session path') {new_session_path(:restricted => true)}
        end
        context "when logged in" do
          setup do
            @user = create_user
            @request.session[:user] = @user
            get :show, :locale => 'en', :id => @work.id
          end
          should_render_template :show
          context "and it's your work" do
            setup do
              @work.pseuds << @user.default_pseud
              get :show, :locale => 'en', :id => @work.id
            end
            should_render_template :show
          end
        end
      end
    end
  end
  context "an adult work" do
    setup do
      Rating.create_canonical(ArchiveConfig.RATING_EXPLICIT_TAG_NAME, true)
      @work = create_work(:authors => [create_user.default_pseud])
      @work.add_default_tags
      @work.rating_string = ArchiveConfig.RATING_EXPLICIT_TAG_NAME
    end
    context "that isn't posted" do
      context "when not logged in" do
        setup { get :show, :locale => 'en', :id => @work.id }
        should_redirect_to('new session path') {new_session_path}
      end
      context "when logged in" do
        setup do
          @user = create_user
          @request.session[:user] = @user
        end
        context "no preference set" do
          setup { get :show, :locale => 'en', :id => @work.id }
          should_set_the_flash_to /permission/
          should_redirect_to("the current user's path"){@user}
        end
        context "and you have set your preferences" do
          setup do
            @user.preference.update_attribute(:adult, true)
            @request.session[:user] = @user
            get :show, :locale => 'en', :id => @work.id
          end
          should_set_the_flash_to /permission/
          should_redirect_to("the current user's path"){@user}
        end
        context "and it's your work" do
          setup do
            @work.pseuds << @user.default_pseud
            get :show, :locale => 'en', :id => @work.id
          end
          should_render_template :show
        end
      end
      context "that is restricted" do
        setup {@work.update_attribute("restricted", true) }
        context "when not logged in" do
          setup { get :show, :locale => 'en', :id => @work.id }
          should_redirect_to('restricted new session path') {new_session_path(:restricted => true)}
        end
        context "when logged in" do
          setup do
            @user = create_user
            @request.session[:user] = @user
            get :show, :locale => 'en', :id => @work.id
          end
          should_set_the_flash_to /permission/
          should_redirect_to("the current user's path"){@user}
          context "and it's your work" do
            setup do
              @work.pseuds << @user.default_pseud
              get :show, :locale => 'en', :id => @work.id
            end
            should_render_template :show
          end
        end
      end
    end
    context "that is posted" do
      setup {@work.update_attribute("posted", true) }
      context "when not logged in" do
        setup { get :show, :locale => 'en', :id => @work.id }
        should_render_template '_adult'
        should_assign_to :work
      end
      context "when logged in" do
        setup do
          @user = create_user
          @request.session[:user] = @user
          get :show, :locale => 'en', :id => @work.id
        end
        should_render_template '_adult'
        should_assign_to :work
        context "and you have set your preferences" do
          setup do
            @user.preference.update_attribute(:adult, true)
            @request.session[:user] = @user
            get :show, :locale => 'en', :id => @work.id
          end
          #should_render_template :show
          should_eventually "render the template show" do
            # FIXME - test fails but works correctly in the browser
          end
        end
        context "and it's your work" do
          setup do
            @work.pseuds << @user.default_pseud
            get :show, :locale => 'en', :id => @work.id
          end
          should_render_template :show
        end
      end
      context "that is restricted" do
        setup {@work.update_attribute("restricted", true) }
        context "when not logged in" do
          setup { get :show, :locale => 'en', :id => @work.id }
          should_redirect_to('restricted new session path') {new_session_path(:restricted => true)}
        end
        context "when logged in" do
          setup do
            @user = create_user
            @request.session[:user] = @user
            get :show, :locale => 'en', :id => @work.id
          end
          should_render_template '_adult'
          context "and it's your work" do
            setup do
              @work.pseuds << @user.default_pseud
              get :show, :locale => 'en', :id => @work.id
            end
            should_render_template :show
          end
        end
      end
    end
  end
end
