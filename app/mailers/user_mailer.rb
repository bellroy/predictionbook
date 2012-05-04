# encoding: utf-8

class UserMailer < ActionMailer::Base
  default :reply_to => Proc.new { no_reply },
          :from     => Proc.new { no_reply }

  def password_reset(user)
    @new_password = user.password

    mail(
      :to       => user.email,
      :subject  => "[PredictionBook] Your password was reset"
    )
  end

private

  def no_reply
    %{"PredictionBook" <no-reply@#{default_url_options[:host]}>}
  end
end

