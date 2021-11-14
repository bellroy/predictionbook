#!/usr/bin/env bash
set -e
# Required for libsass to not shit itself in Nix
bundle config build.sassc --disable-lto
bundle install
bundle exec rake db:create db:schema:load
USE_SELENIUM=1 bundle exec rspec spec
