require 'test_helper'

class WorksEditControllerTest < ActionController::TestCase
  tests WorksController

  context "when not logged in" do
    setup do
      @work = create_work
      get :edit, :locale => 'en', :id => @work.id
    end
      should_set_the_flash_to /have permission/
      should_redirect_to("the work path") {work_path(@work)}
  end

  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
    end

    context "when working with someone else's work" do
      setup do
        new_user = create_user
        @work = create_work(:authors => [new_user.default_pseud])
        get :edit, :locale => 'en', :id => @work.id
      end
      should_set_the_flash_to /have permission/
      should_redirect_to("the work path") {work_path(@work)}
    end

    context "when working with your own work" do
      setup do
        @pseud = create_pseud(:user => @user)
        @chapter = new_chapter(:authors => [@pseud])
        @work = create_work(:authors => [@pseud], :chapters => [@chapter])
        get :edit, :locale => 'en', :id => @work.id
      end
      should_respond_with :success
      should_render_template :edit
      should_assign_to(:work) {@work}
      should_assign_to(:chapter) {@chapter}
      should_assign_to(:pseuds) {[@user.default_pseud, @pseud].sort}
      should_assign_to(:selected_pseuds) {[@pseud.id]}
      should_assign_to(:coauthors) {[]}
      should_assign_to(:series) {[]}
      should "set up form" do
        form = select_form "edit_work_#{@work.id}"
        #assert_same_elements ["_method", "work[rating_string]", "work[warning_strings]", "work[category_string]", "work[fandom_string]", "work[relationship_string]", "work[character_string]", "work[freeform_string]", "work[title]", "work[author_attributes][ids]", "work[author_attributes][coauthors]", "pseud[byline]", "work[summary]", "work[notes]", "work[parent_url]", "work[restricted]", "storyseriescheck", "work[series_attributes][id]", "work[series_attributes][title]", "isWip", "work[wip_length]", "work[chapter_attributes][title]", "work[published_at(3i)]", "work[published_at(2i)]", "work[published_at(1i)]", "work[language_id]", "work[chapter_attributes][content]", "preview_button", "cancel_button"], form.field_names
      end
      context "with no co-authors" do
        setup { get :edit, :locale => 'en', :id => @work.id, :remove => 'me' }
        should_redirect_to("new orphan path") {new_orphan_path(:work_id => @work.id)}
        should_assign_to(:work) {@work}
      end
      context "with co-authors" do
        setup do
          @new_user = create_user
          @work.pseuds << @new_user.default_pseud
          @chapter = create_chapter(:work => @work, :authors => [@pseud])
          get :edit, :locale => 'en', :id => @work.id, :remove => 'me'
        end
        should_set_the_flash_to /have been removed/
        should_redirect_to("the user's path") {user_path(@user)}
        should "remove you as author" do
          assert_equal [@new_user.default_pseud], Work.find(@work.id).pseuds
          assert_equal [@new_user], Work.find(@work.id).users
        end
        should "replace you with co-author on your chapters" do
          assert_equal [@new_user.default_pseud], Chapter.find(@chapter.id).pseuds
        end
      end
    end

  end


end
