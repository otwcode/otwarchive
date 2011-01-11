# takes care of the bundle install tasks
require 'bundler/capistrano'

set :application, "otwarchive"
set :repository,  "http://otwarchive.googlecode.com/svn/branches/deploy/"
set :scm, :subversion
set :deploy_via, :remote_cache

set :auth_methods, "publickey"
#ssh_options[:verbose] = :debug
ssh_options[:auth_methods] = %w(publickey)

set :rails_env, "production"

server "localhost", :app, :web, :db, :primary => true

set :deploy_to, "/var/www/otwarchive"
set :use_sudo, false
set :keep_releases, 4
