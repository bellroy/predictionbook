# frozen_string_literal: true

# Example usage (pushes and tags without user intervention):
#   before 'deploy', 'git:push'
#   after 'deploy:update_code', 'git:tag_deploy'
# If automatic pushing is not desired, git:ensure_pushed should be used to ensure
# that the code you want to deploy is actually accessible in the remote repository
namespace :git do
  set :git_remote, `git config branch.#{fetch(:branch, fetch(:current_branch))}.remote`.chomp

  def sha_ref(file)
    if File.exist?(file)
      IO.read(file).chomp
    else
      IO.read('.git/packed-refs').split("\n").grep(Regexp.new("#{file}$")).first.split(' ').first
    end
  end

  def current_branch
    `git branch`.split("\n").grep(/^\*/).first.gsub(/\*\ /, '').chomp
  end

  def cache_path
    @cache_path ||= "#{shared_path}/#{repository_cache}"
  end

  def git(cmd, &block)
    if block
      run "cd #{cache_path} && git #{cmd}", &block
    else
      run "cd #{cache_path} && git #{cmd}"
    end
  end

  def ensure_remote_cache_strategy!
    abort 'only useful if using remote_cache deploy strategy' unless deploy_via == :remote_cache
  end

  desc 'Pushes current branch to ensure up-to-date deployment'
  task :push do
    exit 1 unless system 'git push'
  end

  desc 'Pulls current branch to ensure up-to-date deployment'
  task :pull do
    exit 1 unless system 'git pull --rebase'
  end

  desc 'Check that the git for the branch are properly set up'
  task :ensure_remote_config do
    no_remote_msg = "no remote setting found, you may need to set git config branch.#{fetch(:branch, current_branch)}.remote <remote_name>"
    warn(no_remote_msg) && exit(1) if git_remote.empty?
  end
end
