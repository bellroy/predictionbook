# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/git-submodule-strategy'
require 'whenever/capistrano'
# require 'capistrano/rvm'
# Dir.glob('lib/capistrano/tasks/trike/deploy.rake').each { |r| import r }
import 'lib/capistrano/tasks/trike/common.rb'
import 'lib/capistrano/tasks/trike/secrets.rake'
import 'lib/capistrano/tasks/trike/precheck.rake'
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
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
# require 'capistrano/rvm'
# require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
