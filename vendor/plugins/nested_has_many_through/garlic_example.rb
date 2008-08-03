# This is for running specs against target versions of rails
#
# To use do
#   - cp garlic_example.rb garlic.rb
#   - rake get_garlic
#   - [optional] edit this file to point the repos at your local clones of
#     rails, rspec, and rspec-rails
#   - rake garlic:all
#
# All of the work and dependencies will be created in the galric dir, and the
# garlic dir can safely be deleted at any point

garlic do
  # default paths are 'garlic/work', and 'garlic/repos'
  # work_path 'garlic/work'
  # repo_path 'garlic/repos'

  # repo, give a url, specify :local to use a local repo (faster
  # and will still update from the origin url)
  repo 'rails', :url => 'git://github.com/rails/rails'#,  :local => "~/dev/vendor/rails"
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'#,  :local => "~/dev/vendor/rspec"
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'#, :local => "~/dev/vendor/rspec-rails"
  repo 'nested_has_many_through', :path => '.'

  # for target, default repo is 'rails', default branch is 'master'
  target 'edge'
  target '2.0-stable', :branch => 'origin/2-0-stable'
  target '2.0.2', :tag => 'v2.0.2'
  target '2.0.3', :tag => 'v2.0.3'
  target '2.1-RC1', :tag => 'v2.1.0_RC1'

  all_targets do
    prepare do
      plugin 'rspec'
      plugin('rspec-rails') { sh "script/generate rspec -f" }
      plugin 'nested_has_many_through', :clone => true # so we can work on it and push fixes upstream
    end
  
    run do
      cd "vendor/plugins/nested_has_many_through" do
        sh "rake spec:rcov:verify"
      end
    end
  end
end
