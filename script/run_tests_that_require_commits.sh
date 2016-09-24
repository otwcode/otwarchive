#!/bin/bash
export DIRTYDB=yes 
bundle exec cucumber features/commit_critical/tag_wrangling_special_b.feature 
bundle exec cucumber features/commit_critical/tag_wrangling_special_c.feature
