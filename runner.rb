require "bundler"
Bundler.require

require 'goliath/runner'
require_relative 'rss_sync'

runner = Goliath::Runner.new(ARGV, nil)
runner.api = RssSync.new
runner.app = Goliath::Rack::Builder.build(RssSync, runner.api)
runner.run
