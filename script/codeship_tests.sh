#!/bin/bash
export RAILS_ENV=test
bash ./script/prepare_codeship.sh
bash ./script/try_command.sh rspec "bundle exec rspec spec "
bundle exec rake db:drop
bash ./script/prepare_codeship.sh
# This rune forces something to succeed. "|| :"
if [ -n "${BROWSERSTACK_USERNAME}" ] ; then
  export TRIES=1
  for i in _windows_10_edge _windows_10_ie _windows_10_firefox _windows_8_opera _windows_10_chrome \
        osx_yosemite_safari _nexus_5 _kindle_fire_2 _ipad_mini_4 ; do
    export CFG_NAME="$i"
    bash ./script/try_command.sh "" "bundle exec cucumber --tags @browserstack -f progress -r features features/\$TEST_RUN"
  done
  export TRIES=3
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
