# frozen_string_literal: true

require "spec_helper"
require "rubocop"
require "rubocop/rspec/cop_helper"
require "rubocop/rspec/expect_offense"
require "rubocop/rspec/host_environment_simulation_helper"
require "rubocop/rspec/shared_contexts"

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{spec/rubocop}) do |metadata|
    metadata[:type] = :rubocop
  end

  config.include CopHelper, type: :rubocop
  config.include HostEnvironmentSimulatorHelper, type: :rubocop
  config.include RuboCop::RSpec::ExpectOffense, type: :rubocop

  config.include_context "config", type: :rubocop
end
