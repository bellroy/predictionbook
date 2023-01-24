# frozen_string_literal: true

require 'ostruct'

module Credentials
  def self.load_dev_config
    credentials_file_path = Rails.root.join('config', 'credentials.yml')
    raise "Missing '#{credentials_file_path}'" unless File.exist?(credentials_file_path)

    credentials = YAML.load_file(credentials_file_path)
    PredictionBook::Application.credentials = OpenStruct.new(credentials)
  end
end
