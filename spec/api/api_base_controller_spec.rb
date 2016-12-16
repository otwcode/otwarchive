require "spec_helper"
require "api/api_helper"

include ApiHelper

describe "Base API Controller" do

  before do
    allow(User).to receive(:is_archivist?).and_return(true)
  end

  before(:each) do
    @under_test = Api::V1::BaseController.new
  end

  describe "batch_errors" do

    describe "with no archivist" do
      it "should return the 'forbidden' status" do
        status, _ = @under_test.instance_eval { batch_errors(nil, api_fields) }
        assert_equal status, :forbidden
      end

      it "should return an error message" do
        _, messages = @under_test.instance_eval { batch_errors(nil, api_fields) }
        assert_equal "The 'archivist' field must specify the name of an Archive user with archivist privileges.", messages[0]
      end
    end

    describe "with a user who is not an archivist" do
      it "should return the 'forbidden' status" do
        allow(User).to receive(:is_archivist?).and_return(false)
        status, _ = @under_test.instance_eval { batch_errors(nil, api_fields) }
        assert_equal status, :forbidden
      end

      it "should return an error message" do
        allow(User).to receive(:is_archivist?).and_return(false)
        _, messages = @under_test.instance_eval { batch_errors(nil, api_fields) }
        assert_equal "The 'archivist' field must specify the name of an Archive user with archivist privileges.", messages[0]
      end
    end
  end

  describe "batch_errors with a valid pseud" do
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

    it "should return error messages with no items to import" do
      user = @user
      _, messages = @under_test.instance_eval { batch_errors(user, nil) }
      assert_equal "No items to import were provided.", messages[0]
    end

    it "should return error messages with too many items to import" do
      user = @user
      loads_of_items = Array.new(210) { |_| api_fields }
      _, messages = @under_test.instance_eval { batch_errors(user, loads_of_items) }
      expect(messages[0]).to start_with "This request contains too many items to import."
    end

    it "should return OK status" do
      user = @user
      status, _ = @under_test.instance_eval { batch_errors(user, api_fields) }
      assert_equal :ok, status
    end

    it "should return no error messages" do
      user = @user
      _, messages = @under_test.instance_eval { batch_errors(user, api_fields) }
      assert_equal 0, messages.size
    end
  end
end
