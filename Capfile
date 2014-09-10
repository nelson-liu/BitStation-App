require 'recap/recipes/rails'

set :application, 'bitstation'
set :repository, 'git@github.com:isundaylee/BitStation-App.git'
# set :user, 'ubuntu'
set :user, 'isundaylee'

ssh_options[:keys] = '/Users/Sunday/.ssh/gce'

# server '54.164.74.107', :app
server '146.148.49.95', :app # GCE

namespace :deploy do
  task :restart do
    as_app 'touch tmp/restart.txt'
  end
end