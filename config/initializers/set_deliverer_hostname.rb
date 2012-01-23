# Overridden when deployed by capistrano with deploy:set_deliverer_hostname
Deliverer.default_url_options[:host] = 'localhost'
Deliverer.default_url_options[:port] = '3000'
