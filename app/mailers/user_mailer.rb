# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def password_reset(user)
    @new_password = user.password

    mail(
      to: user.email,
      subject: '[PredictionBook] Your password was reset'
    )
  end
end
