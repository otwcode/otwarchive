# Prepares a freshly seeded database for the Playwright tests: creates the
# elasticsearch indexes and accepts the current TOS for the login user, so
# the TOS prompt doesn't cover the pages under test.
Indexer.all.map(&:prepare_for_testing)

controller = ApplicationController.new
controller.load_tos_popup
tos_version = controller.instance_variable_get(:@current_tos_version)

login = ENV.fetch("PLAYWRIGHT_USER", "testuser")
User.find_by!(login: login).update_column(:accepted_tos_version, tos_version)
