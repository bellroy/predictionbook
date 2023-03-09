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

  desc 'Nuke the cached checkout on all servers. For those moments when git’s being a git'
  task :nuke_cached_checkouts do
    ensure_remote_cache_strategy!
    run "if [ -d #{cache_path} ]; then rm -rf #{cache_path}; fi"
  end

  desc 'Update submodule remotes so that update will work, should negate the use of nuke_cached_checkouts'
  task :update_submodule_remotes do
    on roles(:app) do
      ensure_remote_cache_strategy!
      git 'checkout master'
      git 'pull origin master'
      modules = []
      git 'submodule status' do |_channel, stream, data|
        modules << data.split(' ')[1] if stream == :out && data =~ /^\+/
      end
      modules.each do |path|
        new_url = nil
        git("config --file .gitmodules submodule.#{path}.url") { |_c, _s, d| new_url = d }
        run "cd #{cache_path}/#{path} && git config remote.origin.url #{new_url} && git fetch origin"
      end
    end
  end

  desc 'Check that the git for the branch are properly set up'
  task :ensure_remote_config do
    no_remote_msg = "no remote setting found, you may need to set git config branch.#{fetch(:branch, current_branch)}.remote <remote_name>"
    warn(no_remote_msg) && exit(1) if git_remote.empty?
  end

  desc 'Check if you have pushed your changes'
  task :ensure_pushed do
    ensure_remote_config
    heads_different_msg = <<-MSG
    It appears you haven’t pushed your changes to the remote repository
    #{repository}. Please do that and repeat.

    If you want to skip this check set the environment variable "SKIP_PUSH_CHECK"
    e.g "SKIP_PUSH_CHECK=yes cap deploy"
    MSG

    branch = fetch(:branch, fetch(:current_branch))
    remote_branch = `git config branch.#{branch}.merge`.chomp.split('/').last
    local_head = sha_ref(".git/refs/heads/#{branch}")
    remote_head = sha_ref(".git/refs/remotes/#{git_remote}/#{remote_branch}")

    unless ENV['SKIP_PUSH_CHECK']
      unless local_head == remote_head
        warn heads_different_msg
        abort "local head: #{local_head}, remote head: #{remote_head}"
      end
    end
  end

  desc 'Check that the trike cap-tasks submodule is up-to-date'
  task :ensure_cap_tasks_uptodate do
    next if ENV['SKIP_CAP_TASKS_CHECK']

    `git submodule status` =~ /
      ([ \+-]) # $1: needs updating if there's a plus sign
      ([0-9a-f]{40}) # $2 the commit's SHA
      \s+
      (.+cap-tasks) # a path containing "cap-tasks"
      /x
    submodule_needs_update = (Regexp.last_match(1) == '+')
    local_head = Regexp.last_match(2)

    warn "Needs update? #{submodule_needs_update}"

    next unless submodule_needs_update

    remote_data = `git ls-remote origin -h refs/heads/master`
    m = remote_data.match /^([0-9a-f]{40})/
    remote_head = m[1]

    warn <<-EOF
      Your cap-tasks submodule is out of date. First, check that you've run
      git submodule update
      Then, if you still get this message, try
      rake trike:update_cap_tasks
      EOF
    abort "local head: #{local_head}, remote head: #{remote_head}"
  end

  desc <<-DESC
    Warn and abort the deployment if the deploy config file wants to be
    deployed from a branch (i.e. has a +set :branch+ directive) but the developer
    deploying isn’t currently on that branch, so she might be thinking she’s
    deploying code that won’t actually end up on the site
  DESC
  task :ensure_deploy_branch do
    deploy_branch = fetch(:branch, nil)
    msg = <<~MSG

      The site you’re deploying is set to deploy from branch '#{deploy_branch}'.
      You however are on branch '#{current_branch}' currently so the result of the
      deployment might not be what you expected.\n
      If you want to skip this check set the environment variable "SKIP_BRANCH_CHECK"
      e.g "SKIP_BRANCH_CHECK=yes cap deploy"
    MSG

    abort(msg) unless ENV['SKIP_BRANCH_CHECK'] || deploy_branch == current_branch
  end
end
