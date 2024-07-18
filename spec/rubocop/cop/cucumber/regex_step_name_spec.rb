# frozen_string_literal: true

require "rubocop_spec_helper"
require_relative "../../../../rubocop/cop/cucumber/regex_step_name"

describe RuboCop::Cop::Cucumber::RegexStepName do
  context "with a `Given` block" do
    it "records a violation when named via regex" do
      expect_offense(<<~INVALID)
        Given /^I have no users$/ do
              ^^^^^^^^^^^^^^^^^^^ Prefer Cucumber expressions (https://github.com/cucumber/cucumber-expressions) over regex for step names; refer to https://github.com/otwcode/otwarchive/wiki/Reviewdog-and-RuboCop if regex is still required
          User.delete_all
        end
      INVALID
    end

    it "does not record a violation when named via a Cucumber expression" do
      expect_no_offenses(<<~RUBY)
        Given "I have no users" do
          User.delete_all
        end
      RUBY
    end
  end

  context "with a `When` block" do
    it "records a violation when named via regex" do
      expect_offense(<<~INVALID)
        When /^I visit the change username page for (.*)$/ do |login|
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer Cucumber expressions (https://github.com/cucumber/cucumber-expressions) over regex for step names; refer to https://github.com/otwcode/otwarchive/wiki/Reviewdog-and-RuboCop if regex is still required
          user = User.find_by(login: login)
          visit change_username_user_path(user)
        end
      INVALID
    end

    it "does not record a violation when named via a Cucumber expression" do
      expect_no_offenses(<<~RUBY)
        When "I request a password reset for {string}" do |login|
          step(%{I am on the login page})
          step(%{I follow "Reset password"})
          step(%{I fill in "Email address or user name" with "\#{login}"})
          step(%{I press "Reset Password"})
        end
      RUBY
    end
  end

  context "with a `Then` block" do
    it "records a violation when named via regex" do
      expect_offense(<<~INVALID)
        Then /^the user "([^"]*)" should be activated$/ do |login|
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer Cucumber expressions (https://github.com/cucumber/cucumber-expressions) over regex for step names; refer to https://github.com/otwcode/otwarchive/wiki/Reviewdog-and-RuboCop if regex is still required
          user = User.find_by(login: login)
          expect(user).to be_active
        end
      INVALID
    end

    it "does not record a violation when named via a Cucumber expression" do
      expect_no_offenses(<<~RUBY)
        Then "I should see the invitation id for the user {string}" do |login|
          invitation_id = User.find_by(login: login).invitation.id
          step %{I should see "Invitation: \#{invitation_id}"}
        end
      RUBY
    end
  end
end
