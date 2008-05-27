require File.dirname(__FILE__) + '/../test_helper'

class BookmarksControllerTest < ActionController::TestCase
  # Test create  POST  /:locale/bookmarks
  def test_create_bookmark
    # FIXME route exists but no action responded
    #post :create, :locale => 'en'
  end
  # Test destroy  DELETE /:locale/bookmarks/:id
  def test_destroy_bookmark
    # FIXME can't create a bookmark until a model is acts_as_bookmarkable
    # bookmark = create_bookmark
    # FIXME route exists but no action responded
    #delete :destroy, :locale => 'en', :id => bookmark.id
  end
  # Test edit  GET  /:locale/bookmarks/:id/edit  (named path: edit_bookmark)
  def test_edit_bookmark_path
    # FIXME can't create a bookmark until a model is acts_as_bookmarkable
    # bookmark = create_bookmark
    # FIXME route exists but no action responded
    # get :edit, :locale => 'en', :id => bookmark.id
  end
  # Test index  GET  /:locale/bookmarks  (named path: bookmarks)
  def test_bookmarks_path
    # FIXME route exists but no action responded
    # get :index, :locale => 'en'
  end
  # Test new  GET  /:locale/bookmarks/new  (named path: new_bookmark)
  def test_new_bookmark_path
    # FIXME route exists but no action responded
    # get :new, :locale => 'en'    
  end
  # Test show  GET  /:locale/bookmarks/:id  (named path: bookmark)
  def test_bookmark_path
    # FIXME can't create a bookmark until a model is acts_as_bookmarkable
    # bookmark = create_bookmark
    # FIXME route exists but no action responded
    # get :show, :locale => 'en', :id => bookmark.id
  end
  # Test update  PUT  /:locale/bookmarks/:id
  def test_update_bookmark
    # FIXME can't create a bookmark until a model is acts_as_bookmarkable
    # bookmark = create_bookmark
    # FIXME route exists but no action responded
    # put :update, :locale => 'en', :id => bookmark.id
  end
end
