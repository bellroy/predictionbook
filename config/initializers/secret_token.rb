# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Rails.env.development? || Rails.env.test?
  PredictionBook::Application.config.secret_key_base = PredictionBook::Application.config.credentials.secret_key_base
else
  PredictionBook::Application.config.secret_key_base = PredictionBook::Application.credentials.secret_key_base
end
