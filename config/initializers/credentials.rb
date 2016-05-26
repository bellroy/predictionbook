require 'ostruct'

credentials_file_path = Rails.root.join('config', 'credentials.yml')
if File.exists?(credentials_file_path)
  credentials = YAML.load_file(credentials_file_path)
  PredictionBook::Application.config.credentials = OpenStruct.new(credentials)
else
  raise "Missing '#{credentials_file_path}'"
end
