$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# load dependencies
require 'goliath'
require 'em-synchrony/em-http'
require 'redis'
require 'json'
require 'active_support/core_ext/object'

# load app
require 'contentful-sync-rss/models/client'
require 'contentful-sync-rss/classes/request_handler'
require 'contentful-sync-rss/classes/response'
require 'contentful-sync-rss/errors'
