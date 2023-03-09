# frozen_string_literal: true

namespace :deploy do
  desc 'Create a robots.txt file denying all robot access'
  task :block_robots do
    on roles(:web) do
      foo_path = "#{current_path}/public"
      puts "current path = #{current_path}"
      puts "fetch current path = #{foo_path}"
      stage = fetch(:stage, nil).to_s
      production_stage = fetch(:production_stage, 'production').to_s
      if ENV['FORCE_BLOCK_ROBOTS'] || stage != production_stage
        execute "echo 'User-agent: *' > #{foo_path}/robots.txt"
        execute "echo 'Disallow: /' >> #{foo_path}/robots.txt"
      elsif stage == production_stage
        warn <<-PRODUCTION_ROBOTS_MSG
        Using deployed robots.txt, which is probably what you want. If you don't
        want this site to be accessible to robots set FORCE_BLOCK_ROBOTS.
        E.g. "FORCE_BLOCK_ROBOTS=yes cap production deploy"
        PRODUCTION_ROBOTS_MSG
      end
    end
  end

  desc 'Restart the Application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
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

  after :finished, :update_slack_message
end
