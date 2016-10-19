require 'spec_helper'
require 'api/api_helper'

include ApiHelper

describe 'Base API Controller' do

  before(:all) do
    module Api
      module V1
        class BaseController
          public :restrict_access, :batch_errors
        end
      end
    end
  end

  after(:all) do
    module Api
      module V1
        class BaseController
          private :restrict_access, :batch_errors
        end
      end
    end
  end

  before(:each) do
    @under_test = Api::V1::BaseController.new
  end

  describe 'restrict_access with no API token' do

  end

  describe 'batch_errors with no archivist' do
    it 'should return the "forbidden" status' do
      status, _ = @under_test.batch_errors(nil, api_fields)
      assert_equal status, :forbidden
    end

    it 'should return an error message' do
      _, messages = @under_test.batch_errors(nil, api_fields)
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
      _, messages = @under_test.batch_errors(user, nil)
      assert_equal 'No items to import were provided.', messages[0]
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
      status, _ = @under_test.batch_errors(@user, api_fields)
      assert_equal :ok, status
    end

    it 'should return no error messages' do
      _, messages = @under_test.batch_errors(@user, api_fields)
      assert_equal 0, messages.size
    end
  end
end
