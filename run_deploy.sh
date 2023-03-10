#!/usr/bin/env bash
set -e

bundle install --without default development test staging linux
AUTO_DEPLOY=1 DEPLOY_BRANCH=$BRANCH bundle exec cap $STAGE deploy
