# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default reply_to: proc { no_reply },
          from: proc { no_reply }

  protected

  def no_reply
    %("PredictionBook" <no-reply@#{default_url_options[:host]}>)
  end
end
