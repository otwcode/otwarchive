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

  CONFIG_NAME="windows_10_edge" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="windows_10_ie" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="windows_10_firefox" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="windows_8_opera" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="windows_10_chrome" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="osx_yosemite_safari" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="osx_yosemite_safari" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="nexus_5" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="kindle_fire_2" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="galaxy_tab4_101" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

  CONFIG_NAME="ipad_mini_4" TRIES=1 bash ./script/try_command.sh "" \
  "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"

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
