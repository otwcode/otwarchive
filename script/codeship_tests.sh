#!/bin/bash
export RAILS_ENV=test
bash ./script/prepare_codeship.sh
TRIES=1 bash ./script/try_command.sh /other_b/browserstack_demo.feature "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
exit 0
bash ./script/try_command.sh rspec "bundle exec rspec spec "
bundle exec rake db:drop
bash ./script/prepare_codeship.sh
# This rune forces something to succeed. "|| :"
bash ./script/try_command.sh admins             "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh bookmarks          "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh collections        "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh comments_and_kudos "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh gift_exchanges     "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh importing          "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh other_a            "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh other_b            "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh prompt_memes_a     "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh prompt_memes_b     "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh prompt_memes_c     "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh tags_and_wrangling "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh users              "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bash ./script/try_command.sh works              "bundle exec cucumber -f progress -r features features/\$TEST_RUN"
bundle exec rake coveralls:push
