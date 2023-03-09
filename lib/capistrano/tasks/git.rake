# frozen_string_literal: true

namespace :git do
  set :git_remote, `git config branch.#{fetch(:branch, fetch(:current_branch))}.remote`.chomp

  desc 'Pulls current branch to ensure up-to-date deployment'
  task :pull do
    exit 1 unless system 'git pull --rebase'
  end
end
