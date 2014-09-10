require 'recap/recipes/rails'

set :application, 'bitstation_gce'
set :repository, 'git@github.com:isundaylee/BitStation-App.git'
# set :user, 'ubuntu'
set :user, 'bitstation'

ssh_options[:keys] = '/Users/Sunday/.ssh/gce'

# server '54.164.74.107', :app
server '107.178.209.244', :app # GCE

namespace :deploy do
  task :restart do
    as_app 'touch tmp/restart.txt'
  end
end