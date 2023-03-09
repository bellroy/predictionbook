# frozen_string_literal: true

namespace :deploy do
  desc 'Tag deployed release'
  task :tag do
    run_locally do
      if ENV['SKIP_DEPLOY_TAGGING'] || fetch(:skip_deploy_tagging, false)
        info '[cap-deploy-tagger] Skipped deploy tagging'
      else
        tag_name = "#{Time.now.utc.strftime('%Y%m%d%H%M')}_#{fetch(:stage)}"
        latest_revision = fetch(:current_revision)
        unless fetch(:sshkit_backend) == SSHKit::Backend::Printer # unless --dry-run flag present
          execute :git, "tag -f #{tag_name} #{latest_revision}"
          execute :git, 'push -f --tags'
        end
        info "[cap-deploy-tagger] Tagged #{latest_revision} with #{tag_name}"
      end
    end
  end
end
