require 'goliath/runner'
require_relative 'proxy'

runner = Goliath::Runner.new(ARGV, nil)
runner.api = ContentfulSyncRss::Proxy.new
runner.app = Goliath::Rack::Builder.build(ContentfulSyncRss::Proxy, runner.api)
runner.run
