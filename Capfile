require 'recap/recipes/rails'

set :application, 'bitstation'
set :repository, 'git@github.com:isundaylee/BitStation-App.git'
# set :user, 'ubuntu'
set :user, 'root'

# ssh_options[:keys] = '/Users/Sunday/.ssh/gce'

# server '54.164.74.107', :app
# server '146.148.49.95', :app # GCE
server '104.131.68.90', :app

namespace :deploy do
  task :restart do
    as_app 'touch tmp/restart.txt'
  end
end