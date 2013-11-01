$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# load dependencies
require 'goliath'
require 'em-synchrony/em-http'
require 'redis'
require 'json'
require 'yaml'

# load app
require 'contentful-sync-rss/models/client'
require 'contentful-sync-rss/errors'
