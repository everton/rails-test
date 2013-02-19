require 'bundler/capistrano'

set :application, 'bc-test'
set :deploy_to,   '/var/www/bc-test'

set :shared_children, %w(public/system public/images log tmp/pids tmp/cache)

set :scm, :git
set :repository,  'git@github.com:everton/rails-test.git'
set :branch,      'master'

set :user, 'root'
set :use_sudo, false

role :web, '192.155.83.107'
role :app, '192.155.83.107'
role :db,  '192.155.83.107', primary: true
