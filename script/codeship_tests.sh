#!/bin/bash
export RAILS_ENV=test
bash ./script/prepare_codeship.sh
TRIES=1 bash ./script/try_command.sh "" "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"
exit 0
bash ./script/try_command.sh rspec "bundle exec rspec spec "
bundle exec rake db:drop
bash ./script/prepare_codeship.sh
# This rune forces something to succeed. "|| :"
if [ -n "${BROWSERSTACK_USERNAME}" ] ; then
  export TRIES = 1
  CFG_NAME="_windows_10_edge" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_windows_10_ie" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_windows_10_firefox" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_windows_8_opera" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_windows_10_chrome" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_osx_yosemite_safari" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_nexus_5" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_kindle_fire_2" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_galaxy_tab4_101" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CFG_NAME="_ipad_mini_4" bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"
  export TRIES = 3
fi
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
