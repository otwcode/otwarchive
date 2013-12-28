require 'test_helper'

class WorksCreateControllerTest < ActionController::TestCase
  tests WorksController

  context "when not logged in" do
    setup { post :create, :locale => 'en' }
    should_redirect_to("new session") {new_session_url}
  end
  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
    end
    context "basic create" do
      setup do
        @title = random_phrase
        @content = random_paragraph
        @fandom = random_phrase
        @chapter_attribs = {"title"=>"", "content"=>@content}
        @author_attribs = {"ids"=>[@user.default_pseud.id]}
        @rating = "Not Rated"
        @warning = ["Choose Not To Use Archive Warnings"]
      end
      context "without title" do
        setup do
          post :create, :locale => 'en', "preview_button"=>"Preview", 
            "work"=>{"chapter_attributes"=>@chapter_attribs,"author_attributes"=>@author_attribs, "title"=>"", "fandom_string"=>@fandom, 
                    "rating_string"=>@rating, "warning_strings"=>@warning, "wip_length"=>"1"}
        end
        should_render_template :new
        should_assign_to :work
      end
      context "without fandom" do
        setup do
          post :create, :locale => 'en', "preview_button"=>"Preview", 
            "work"=>{"chapter_attributes"=>@chapter_attribs,"author_attributes"=>@author_attribs, "title"=>@title, "fandom_string"=>"", 
                    "rating_string"=>@rating, "warning_strings"=>@warning, "wip_length"=>"1"}
        end
        should_render_template :new
        should_assign_to :work
        should "have some errors" do
          assert assigns(:work).errors.on(:base)
          assert_match /Fandom is missing/, assigns(:work).errors.on(:base).to_s
        end
      end
      context "without other required tags" do
        setup do
          post :create, :locale => 'en', "preview_button"=>"Preview", 
            "work"=>{"chapter_attributes"=>@chapter_attribs,"author_attributes"=>@author_attribs, "title"=>@title, "fandom_string"=>@fandom, 
                    "rating_string"=>"", "warning_strings"=>"", "wip_length"=>"1"}
          @work = Work.find_by_title(@title) 
        end
        should_render_template :new
        should_assign_to :work
        should "have some errors" do
          assert assigns(:work).errors.on(:base)
        end
      end      
      context "with bare required attributes" do
        setup do
          post :create, :locale => 'en', "preview_button"=>"Preview", 
            "work"=>{"chapter_attributes"=>@chapter_attribs,"author_attributes"=>@author_attribs, "title"=>@title, "fandom_string"=>@fandom, 
                    "rating_string"=>@rating, "warning_strings"=>@warning, "wip_length"=>"1"}

          @work = Work.find_by_title(@title)                    
        end
        should_redirect_to("preview path") {preview_work_path(@work)}
        should_assign_to :work
        should "set the first chapter content" do
          assert_match @work.chapters.first.content, @content
        end
      end
      context "with collection to which the user can post" do
        setup do
          @collection = create_collection
          post :create, :locale => 'en', "preview_button"=>"Preview", 
            "work"=>{"chapter_attributes"=>@chapter_attribs,"author_attributes"=>@author_attribs, "title"=>@title, "fandom_string"=>@fandom, 
                    "rating_string"=>@rating, "warning_strings"=>@warning, "wip_length"=>"1", :collection_names => @collection.name}
          @work = Work.find_by_title(@title)                    
        end
        should_redirect_to("preview path") {preview_work_path(@work)}
        should_assign_to :work
        should "add the work to the collection" do
          assert @collection.works.include?(@work)
          assert @work.approved_collections.include?(@collection)
          @work.update_attribute(:posted, true)
          assert @collection.approved_works.include?(@work)
        end
      end
    end
  end


  
  # TODO: REWRITE WITHOUT FORM_TEST_HELPER CODE
  
  # context "when logged in" do
  #   setup do
  #     @user = create_user
  #     @request.session[:user] = @user
  #   end
  #   context "creating an invalid work" do
  #     setup { post :create, :controller => 'works', :locale => 'en' }
  #     should_render_template 'new'
  #   end
  #   context "canceling a work" do
  #     setup do
  #       @unposted = create_work(:created_at => 2.weeks.ago)
  #       get :new, :controller => 'works', :locale => 'en'
  #       form = select_form "new_work"
  #       form.cancel_button='Cancel'
  #       form.preview_button=nil
  #       form.submit
  #     end
  #     should_set_the_flash_to /canceled/
  #     should_redirect_to("the users's path") {user_path(@user)}
  #   end
  #   context "creating a valid work" do
  #     setup do
  #       @pseud = create_pseud(:user => @user)
  #       @co_author_pseud = create_user.default_pseud
  #       @related_work = create_work(:authors => [@co_author_pseud])
  # 
  #       get :new, :controller => 'works', :locale => 'en'
  # 
  #       form = select_form "new_work"
  #       form.work.title="every field filled"
  #       form.work.author_attributes.ids=[@pseud.id]
  #       form.pseud.byline=@co_author_pseud.name
  #       form.work.chapter_attributes.title="first chapter"
  #       form.work.chapter_attributes.content="chapter content"
  #       form.work.chapter_attributes["published_at(1i)"]="2005"
  #       form.work.chapter_attributes["published_at(2i)"]="11"
  #       form.work.chapter_attributes["published_at(3i)"]="7"
  #       form.work.backdate=false
  #       form.work.wip_length="17"
  #       form.work.series_attributes.title="a new series"
  #       form.work.restricted="1"
  #       form.work.rating_string=ArchiveConfig.RATING_EXPLICIT_TAG_NAME
  #       form.work.warning_strings=
  #           ["Graphic Depictions Of Violence", "Major Character Death", "Underage"]
  #       form.work.category_string=ArchiveConfig.CATEGORY_MULTI_TAG_NAME
  #       form.work.fandom_string="Harry Potter, xover"
  #       form.work.relationship_string=
  #         "character3/everyone, character4/character6/character5"
  #       form.work.character_string="character1, character2"
  #       form.work.freeform_string="free tag, another free tag"
  #       form.work.notes="notes go here"
  #       form.work.summary="summary goes here"
  #       form.work.parent_url=
  #           ArchiveConfig.APP_URL + "/en/works/" + @related_work.id.to_s
  #       form.cancel_button=nil
  #       form.preview_button='Preview'
  #       form.submit
  #     end #setup
  #     # do all test in one should, so they don't re-create the work each time
  #     should "save the work based on the form" do
  #       assert_match 'successfully created', flash[:notice]
  #       assert @work = Work.find_by_title("every field filled")
  #       assert_redirected_to preview_work_path(@work)
  #       # belongs to user
  #       assert_equal @work, User.find(@user.id).works.first
  #       # tags
  #       assert_equal Rating.find_by_name(ArchiveConfig.RATING_EXPLICIT_TAG_NAME), @work.ratings.first
  #       assert_equal "Graphic Depictions Of Violence, Major Character Death, Underage" , @work.warning_string
  #       assert_equal Category.find_by_name(ArchiveConfig.CATEGORY_MULTI_TAG_NAME), @work.categories.first
  #       assert_equal ["Harry Potter", "xover"], @work.fandoms.map(&:name)
  #       assert_contains(@work.relationships, Relationship.find_by_name("character3/everyone"))
  #       assert_equal Character.find_by_name("character1"), @work.characters.first
  #       assert_equal ["free tag", "another free tag"], Freeform.all.map(&:name)
  #       # restricted
  #       assert @work.restricted
  #       # wip
  #       assert @work.is_wip
  #       assert_equal 17, @work.expected_number_of_chapters
  #       # series
  #       assert_equal @work, Series.find_by_title("a new series").works.first
  #       # chapter
  #       @chapter = @work.first_chapter
  #       assert_equal "chapter content", @chapter.content
  #       assert_equal "first chapter", @chapter.title
  #       assert_equal "2005-11-07", @chapter.published_at.to_s
  #       # notes and summary
  #       assert_equal "notes go here", @work.notes
  #       assert_equal "summary goes here", @work.summary
  #       # parent
  #       assert_equal [@related_work], @work.parents.uniq
  #       assert_equal [@work], @related_work.children.uniq
  #       assert_equal [@pseud.id, @co_author_pseud.id], @work.pseuds.map(&:id)
  #      end
  #   end #context preview
  # end #context logged in
end
