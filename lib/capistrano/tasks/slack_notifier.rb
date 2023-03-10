# typed: true
# frozen_string_literal: true

require 'httparty'

class SlackNotifier
  def self.singleton(webhook_urls: nil, deploy_message: nil, message_attachments: nil)
    unless @singleton.nil?
      return @singleton if webhook_urls.nil? && deploy_message.nil? && message_attachments.nil?
      return @singleton if @singleton.webhook_urls == webhook_urls &&
                           @singleton.deploy_message == deploy_message &&
                           @singleton.message_attachments == message_attachments
    end

    if webhook_urls.nil? && deploy_message.nil? && message_attachments.nil?
      raise 'Cannot call SlackNotifier.singleton with no arguments before it is initialized'
    end

    @singleton = new(webhook_urls, deploy_message, message_attachments)
  end

  attr_reader :webhook_urls, :deploy_message, :message_attachments

  def initialize(webhook_urls, message, attachments)
    @webhook_urls = webhook_urls
    @message = message
    @attachments = attachments
  end

  def post_pre_deployment_message
    @post_pre_deployment_message ||= post_message_to_all_slack_channels(full_message)
  end

  def post_deployment_success_message
    return unless @post_deployment_success_message.nil?

    @post_deployment_success_message = true
    post_message_to_all_slack_channels(
      "#{full_message} | succeeded! :tada:",
      include_attachments: false
    )
  end

  def post_deployment_failure_message
    return unless @post_deployment_failure_message.nil?

    @post_deployment_failure_message = true
    post_message_to_all_slack_channels(
      "#{full_message} | failed! :collision:",
      include_attachments: false
    )
  end

  private

  def full_message
    text = []
    text << ":loudspeaker: *#{current_user}* is"
    text << @message
    text.flatten.join(' ')
  end

  def current_user
    @current_user ||= begin
      value = `git config --get user.name`.strip
      value = "person who hasn't set up their git config user.name" if value.empty?
      value
    end
  end

  def post_message_to_all_slack_channels(message, include_attachments: true)
    attachments = include_attachments ? @attachments : []
    payload = {
      body: { text: message, attachments: attachments }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    }
    @webhook_urls.each do |slack_webhook_url|
      ::HTTParty.post(slack_webhook_url, payload)
    end
    true
  end
end
