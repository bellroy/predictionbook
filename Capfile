require 'capistrano/server_definition'
require 'capistrano/role'
class Capistrano::Configuration
  def role_names_for_host(host)
    roles.map {|role_name, role| role_name if role.include?(host) }.compact || []
  end
end

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# Uncomment if you are using Rails' asset pipeline
# load 'deploy/assets'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy.rb' # remove this line to skip loading any of the default tasks
