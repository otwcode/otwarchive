require 'test_helper'
require 'exception_notifier_helper'

class ExceptionNotifierHelperTest < Test::Unit::TestCase

  class ExceptionNotifierHelperIncludeTarget
    include ExceptionNotifierHelper
  end

  def setup
    @helper = ExceptionNotifierHelperIncludeTarget.new
  end

  # No controller
  
  def test_should_not_exclude_raw_post_parameters_if_no_controller
    assert !@helper.exclude_raw_post_parameters?
  end
  
  # Controller, no filtering
  
  class ControllerWithoutFilterParameters; end

  def test_should_not_filter_env_values_for_raw_post_data_keys_if_controller_can_not_filter_parameters
    stub_controller(ControllerWithoutFilterParameters.new)
    assert @helper.filter_sensitive_post_data_from_env("RAW_POST_DATA", "secret").include?("secret")
  end
  def test_should_not_exclude_raw_post_parameters_if_controller_can_not_filter_parameters
    stub_controller(ControllerWithoutFilterParameters.new)
    assert !@helper.exclude_raw_post_parameters?    
  end
  def test_should_return_params_if_controller_can_not_filter_parameters
    stub_controller(ControllerWithoutFilterParameters.new)
    assert_equal :params, @helper.filter_sensitive_post_data_parameters(:params)
  end

  # Controller with filtering

  class ControllerWithFilterParameters
    def filter_parameters(params); :filtered end
  end

  def test_should_filter_env_values_for_raw_post_data_keys_if_controller_can_filter_parameters
    stub_controller(ControllerWithFilterParameters.new)
    assert !@helper.filter_sensitive_post_data_from_env("RAW_POST_DATA", "secret").include?("secret")
    assert @helper.filter_sensitive_post_data_from_env("SOME_OTHER_KEY", "secret").include?("secret")
  end
  def test_should_exclude_raw_post_parameters_if_controller_can_filter_parameters
    stub_controller(ControllerWithFilterParameters.new)
    assert @helper.exclude_raw_post_parameters?
  end
  def test_should_delegate_param_filtering_to_controller_if_controller_can_filter_parameters
    stub_controller(ControllerWithFilterParameters.new)
    assert_equal :filtered, @helper.filter_sensitive_post_data_parameters(:params)
  end
  
  private
    def stub_controller(controller)
      @helper.instance_variable_set(:@controller, controller)
    end
end