require 'spec_helper'
require 'api/api_helper'

include ApiHelper

describe 'Base API Controller' do

  before(:each) do
    @under_test = Api::V1::BaseController.new
  end

  describe 'batch_errors with no archivist' do
    it 'should return the "forbidden" status' do
      status, _ = @under_test.instance_eval { batch_errors(nil, api_fields) }
      assert_equal status, :forbidden
    end

    it 'should return an error message' do
      _, messages = @under_test.instance_eval { batch_errors(nil, api_fields) }
      assert_equal "The 'archivist' field must specify the name of an Archive user with archivist privileges.", messages[0]
    end
  end

  describe 'batch_errors with no items' do
    # Override is_archivist so all users are archivists from this point on
    class User < ActiveRecord::Base
      def is_archivist?
        true
      end
    end

    it 'should return error messages with no items to import' do
      user = create(:user)
      _, messages = @under_test.instance_eval { batch_errors(user, nil) }
      assert_equal 'No items to import were provided.', messages[0]
    end
  end

  describe 'batch_errors with too many items' do
    # Override is_archivist so all users are archivists from this point on
    class User < ActiveRecord::Base
      def is_archivist?
        true
      end
    end

    it 'should return error messages with too many items to import' do
      user = create(:user)
      loads_of_items = Array.new(210) { |i| api_fields }
      puts loads_of_items[0]
      _, messages = @under_test.instance_eval { batch_errors(user, loads_of_items) }
      assert_equal 'This request contains too many items to import. A maximum of 200 items can be imported at one time by an archivist.', messages[0]
    end
  end

  describe 'batch_errors with a valid pseud and items' do
    # Override is_archivist so all users are archivists from this point on
    class User < ActiveRecord::Base
      def is_archivist?
        true
      end
    end

    before(:each) do
      @user = create(:user)
    end

    after(:each) do
      @user.destroy
    end

    it 'should return OK status' do
      user = @user
      status, _ = @under_test.instance_eval { batch_errors(user, api_fields) }
      assert_equal :ok, status
    end

    it 'should return no error messages' do
      user = @user
      _, messages = @under_test.instance_eval { batch_errors(user, api_fields) }
      assert_equal 0, messages.size
    end
  end
end
