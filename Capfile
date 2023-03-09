# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/rails'
require 'capistrano/bundler'
require 'whenever/capistrano'

# Use Git
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
require 'capistrano/rails/migrations'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
