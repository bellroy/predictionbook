# frozen_string_literal: true

namespace :deploy do
  namespace :precheck do
    require File.join(File.dirname(__FILE__), 'slack_notifier')

    desc 'Reminds developers that evenings and weekends are important'
    task :protect_evenings_and_weekends do
      puts 'Weekends and evenings should be yours to enjoy. Deploying after 4pm on a weekday, ' \
           'and after midday on Friday, potentially compromises that. Are you sure you ' \
           'want to proceed?'
      set(:confirm, ask('Y|N', 'N'))
      abort('Aborting Deploy') if fetch(:confirm, 'N') != 'Y'
    end

    desc 'Notifies slack of deployment'
    task :notify do
      if ENV['AUTO_DEPLOY']
        set :user_message, 'Deploy all the things'
      else
        set :user_message, ask('a short description of what is being deployed (optional)', nil)
      end
      notifier.post_pre_deployment_message
    end

    desc 'Displays diff and requests user to confirm this is what they want to deploy'
    task :verify_diff do
      puts 'generating diff between this deployment and the last deployment for your review...'
      system(
        'git',
        'diff',
        last_origin_branch_deploy_tag_or_commit,
        'origin/stable',
        ':(top,exclude)sorbet/rbi/gems/*.rbi',
        ':(top,exclude)sorbet/rbi/hidden-definitions/errors.txt'
      )
      puts 'Continue with deployment?'
      set(:confirm, ask('Y|N', 'N'))
      abort('Aborting Deploy') if fetch(:confirm, 'N') != 'Y'
    end

    def current_branch
      `git symbolic-ref --short HEAD`.chomp
    end

    DEV_ANNOUNCE_SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/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'

    def notifier
      @notifier ||= SlackNotifier.singleton(
        webhook_urls: fetch(:slack_webhook_urls, [DEV_ANNOUNCE_SLACK_WEBHOOK_URL]),
        deploy_message: deploy_message,
        message_attachments: message_attachments
      )
    end

    def deploy_stage
      fetch(:rails_env, 'unknown environment')
    end

    def user_message
      fetch(:user_message, nil)
    end

    def deploy_message
      folder_name_command = 'basename `git rev-parse --show-toplevel`'
      application_label = fetch(:application_label) || `#{folder_name_command}`.strip
      [
        'deploying',
        "*#{application_label}*",
        'to',
        "*#{deploy_stage}*",
        'from',
        "*#{current_branch}*",
        !user_message.nil? && !user_message.empty? ? "(#{user_message})" : nil
      ].compact.join(' ')
    end

    def message_attachments
      [
        {
          fallback: 'Deployment summary',
          color: '#36a64f',
          pretext: deployment_log_message,
          fields: [
            {
              title: "What's being deployed",
              value: commit_messages_from_origin_branch.join("\n"),
              short: false
            }
          ]
        }
      ]
    end

    def deployment_log_message
      return nil if ENV['LOG_URL'].nil?

      "Deployment log available at #{ENV['LOG_URL']}"
    end

    def origin_branch
      @origin_branch ||= "origin/#{current_branch}"
    end

    def execute_system_command(command)
      `#{command}`
    end

    def commit_messages_from_origin_branch
      return [] unless deploying_from_git_repo?

      execute_system_command(
        "git log --oneline --format=\"%s\" #{last_origin_branch_deploy_tag_or_commit}..#{origin_branch} " \
        '| grep -v "Merge pull request" ' \
        "| grep -v \"Merge branch 'master' into\" " \
        '| cat'
      ).split("\n")
    end

    def deploying_from_git_repo?
      return @deploying_from_git_repo unless @deploying_from_git_repo.nil?

      @deploying_from_git_repo = execute_system_command('git status') != ''
    end

    def last_origin_branch_deploy_tag_or_commit
      result = execute_system_command("git tag -l [0-9]*_#{deploy_stage} | tail -n 1").strip
      if result == ''
        result = execute_system_command("git log --oneline --format=\"%H\" -n 10 #{origin_branch} | tail -n 1").strip
      end
      result
    end

    def outside_of_allowed_deploy_times?
      local_day_and_time = `date '+%A %R'`
      local_day_and_time.match(/(Monday|Tuesday|Wednesday|Thursday) (16|17|18|19|20|21|22|23)/) ||
        local_day_and_time.match(/Friday (12|13|14|15|16|17|18|19|20|21|22|23)/) ||
        local_day_and_time.match(/(Saturday|Sunday)/)
    end

    desc 'Warn and abort the deployment if the deploy config file wants to be ' \
         'deployed from a branch (i.e. has a +set :branch+ directive) but the developer ' \
         "deploying isn't currently on that branch, so she might be thinking she's " \
         "deploying code that won't actually end up on the site"
    task :ensure_deploy_branch do
      deploy_branch = fetch(:branch, nil)
      environment = fetch(:rails_env, nil)
      msg = <<-MSG
      The site you're deploying is set to deploy from branch '#{deploy_branch}'.\n
      You are on branch '#{current_branch}' currently so the result of the
      deployment might not be what you expected.\n
      If you want to skip this check set the environment variable "SKIP_BRANCH_CHECK"
      e.g "SKIP_BRANCH_CHECK=yes cap #{environment} deploy"\n
      You can also override the branch by setting the "DEPLOY_BRANCH" environment variable
      e.g. "DEPLOY_BRANCH=#{current_branch} cap #{environment} deploy"
      MSG

      abort(msg) unless ENV['SKIP_BRANCH_CHECK'] || deploy_branch == current_branch
    end

    desc 'Fails unless can connect to the servers in the deploy'
    task :ensure_access_to_deploy_servers do
      on roles(:app) do |server|
        next if system("ping -c 1 #{server.hostname}", out: File::NULL)

        abort("Cannot reach deploy server #{server.hostname}. Check that your VPN is on.")
      end
    end

    desc 'Runs all prechecks'
    task :all do
      invoke('git:pull')
      unless ENV['AUTO_DEPLOY']
        invoke('deploy:precheck:ensure_access_to_deploy_servers')
        invoke('deploy:precheck:ensure_deploy_branch')
        invoke('deploy:precheck:protect_evenings_and_weekends') if fetch(:stage) == :production && outside_of_allowed_deploy_times?
        invoke('deploy:precheck:verify_diff') if fetch(:stage) == :production
      end
      invoke('deploy:precheck:notify')
    end
  end
end

before 'deploy:starting', 'deploy:precheck:all'
