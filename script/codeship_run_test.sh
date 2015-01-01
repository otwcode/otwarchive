#!/bin/bash
bundle exec rspec spec
rake db:drop
bash ./script/prepare_codeship.sh
# This rune forces something to succeed. "|| :"
bundle exec cucumber -f progress -r features features/admins
#bundle exec cucumber -f progress -r features features/bookmarks -b || :
bundle exec cucumber -f progress -r features features/collections -b
bundle exec cucumber -f progress -r features features/comments_and_kudos -b
bundle exec cucumber -f progress -r features features/gift_exchanges -b
#bundle exec cucumber -f progress -r features features/importing -b || :
bundle exec cucumber -f progress -r features features/other_a -b
#bundle exec cucumber -f progress -r features features/other_b -b
bundle exec cucumber -f progress -r features features/prompt_memes_a -b
bundle exec cucumber -f progress -r features features/prompt_memes_b -b
bundle exec cucumber -f progress -r features features/tags_and_wrangling -b
bundle exec cucumber -f progress -r features features/users -b
bundle exec cucumber -f progress -r features features/works -b
