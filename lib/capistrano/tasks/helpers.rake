# frozen_string_literal: true

# Helper method to get the path of the remote “current” dir
# Example:
#   +current('public','javascripts')+
#   +current('public/robots.txt')+
def current(*args)
  File.join(current_path, *args)
end

# Helper method to be able to build tasks that are able to run both
# within a new deployment process before the  and after the fact, operating on the most
# recent (the “current”) deployment
def run_in_release_path_or_current_path(cmd, options = {}, &block)
  conditional_cmd = %(if [ -d '#{release_path}' ]; then cd #{release_path} && #{cmd}; else cd #{current_path} && #{cmd}; fi)
  run(conditional_cmd, options, &block)
end

def copy_if_exists(file1, file2, sudo = false)
  cmd = "if [ -r #{file1} ];then cp #{file1} #{file2};fi"
  # there are peculiarities when running if syntax through sudo, so we need
  # another sub-shell with sudo rights here
  sudo ? sudo("sh -c '#{cmd}'") : run(cmd)
end

def sudo_copy_if_exists(file1, file2)
  copy_if_exists(file1, file2, true)
end

def confirmed?(question)
  Capistrano::CLI.ui.ask("#{question} (y/n)") == 'y'
end
