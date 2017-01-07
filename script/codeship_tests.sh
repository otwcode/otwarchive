#!/bin/bash
# The expectation is that this script is copied in to the test area
# on codeship rather than run as a single script as having timings for 
# each stage is useful.
export RAILS_ENV=test
bash ./script/prepare_codeship.sh
bash ./script/try_command.sh rspec "bundle exec rspec spec "
bundle exec rake db:drop
bash ./script/prepare_codeship.sh
echo 'Skin.load_site_css; Skin.where(cached: true).each{|skin| skin.cache!}' | bundle exec rails c  > /dev/null
if [ -n "${BROWSERSTACK_USERNAME}" ] ; then
  export TRIES=1
  for i in config/browserstack/browserstack*.config.yml do
    export CFG_NAME="../${i}"
    bash ./script/try_command.sh "other_b/browserstack_demo.feature" "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"
  done
  export TRIES=3
fi
CFG_NAME="browserstack/browserstack_windows_10_chrome.config.yml" bash ./script/try_command.sh "browserspec" "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh admins             "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh bookmarks          "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh collections        "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh comments_and_kudos "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh gift_exchanges     "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh importing          "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh other_a            "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh other_b            "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh prompt_memes_a     "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh prompt_memes_b     "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh prompt_memes_c     "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh tags_and_wrangling "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh users              "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh works              "bundle exec cucumber --tags ~@browserstack -f progress -r features features/\$TEST_RUN"
bundle exec rake coveralls:push
