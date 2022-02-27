# in an initializer, like sentry.rb
Sentry.init do |config|
  if Rails.env.production?
    config.dsn = 'https://a45d08b7a70740c7bf3c5faa4e738a01:f798bf1072b64386b0b8090a38e74a7a@app.getsentry.com/79390'
  end
end
