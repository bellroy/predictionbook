# frozen_string_literal: true

namespace :deploy do
  desc 'Restart the Application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Fetch environment credentials key'
  task :set_credentials_key do
    on roles(:app), in: :sequence, wait: 5 do
      execute :mkdir, "-p #{shared_path}/config/credentials"
      execute :echo, "\"$RAILS_#{fetch(:stage).upcase}_KEY\" > #{shared_path}/config/credentials/#{fetch(:stage)}.key"
    end
  end

  desc 'Update slack message to say whether deploy succeeded or failed'
  task :update_slack_message do
    on roles(:app) do
      SlackNotifier.singleton.post_deployment_success_message
    end
  end

  after 'deploy:failed', :failed do
    on roles(:app) do
      SlackNotifier.singleton.post_deployment_failure_message
    end
  end
end
