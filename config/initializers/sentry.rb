# in an initializer, like sentry.rb
Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.dsn = 'https://a45d08b7a70740c7bf3c5faa4e738a01:f798bf1072b64386b0b8090a38e74a7a@app.getsentry.com/79390'
  config.environments = ['production']
end
