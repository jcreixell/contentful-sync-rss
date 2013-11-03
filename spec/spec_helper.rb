require 'goliath/test_helper'
require 'mock_redis'
require 'webmock/rspec'

require_relative '../proxy'

module Helpers
  def async
    if EM.reactor_running?
      yield
    else
      out = nil
      EM.synchrony do
        out = yield
        EM.stop
      end
      out
    end
  end
end

$redis = MockRedis.new

class Goliath::Server
  def load_config(file = nil)
    config['redis'] = $redis
  end
end

RSpec.configure do |config| 
  config.include Helpers
  config.include Goliath::TestHelper, :example_group => {
    :file_path => /spec/
  }

  config.before(:suite) do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  config.before(:each) do
    $redis.flushdb
  end
end
