# frozen_string_literal: true

# Usage:
#
# - set a secrets repo in deploy.rb:
#   'set :secrets_repository, 'git@git.trikeapps.com:secrets/<name>.git'
# - call 'secrets:update_configs' before symlinking to the app config folder

namespace :secrets do
  def secrets_path
    @secrets_path ||= "#{shared_path}/secrets"
  end

  task :ensure_secrets_repo_up_to_date do
    on roles(:app) do
      execute "cd #{shared_path} && if [ ! -d secrets ]; then git clone #{fetch(:secrets_repository)} secrets; fi"
      execute "cd #{secrets_path} && git fetch origin && git checkout origin/master -f"
    end
  end

  task :symlink_configs do
    on roles(:app) do
      execute "cd #{shared_path}/config && for f in $(ls -d #{secrets_path}/#{fetch(:stage)}/*); do ln -fs $f; done"
      execute "cd #{shared_path}/config && for f in $(ls -d #{secrets_path}/#{fetch(:stage)}/.[!.]*); do ln -fs $f; done"
    end
  end

  task :symlink_override_configs do
    on roles(:app) do
      dir = "#{secrets_path}/#{fetch(:stage)}/$CAPISTRANO:HOST$"
      execute "cd #{shared_path}/config && if [ -d #{dir} ]; then for f in $(ls -d #{dir}/*); do ln -fs $f; done; fi"
    end
  end

  task update_configs: %w[
    secrets:ensure_secrets_repo_up_to_date
    secrets:symlink_configs
    secrets:symlink_override_configs
  ]
end
