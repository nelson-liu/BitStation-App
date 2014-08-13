require 'recap/recipes/rails'

set :application, 'bitstation'
set :repository, 'git@github.com:nelson-liu/BitStation-App.git'
set :user, 'ubuntu'

server '54.164.74.107', :app

namespace :deploy do
  task :restart do
    as_app 'touch tmp/restart.txt'
  end
end