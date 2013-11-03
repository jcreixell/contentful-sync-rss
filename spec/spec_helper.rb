require 'goliath/test_helper'
require 'mock_redis'
require 'webmock/rspec'

$redis = MockRedis.new

class Goliath::Server
  def load_config(file = nil)
    config['redis'] = $redis
  end
end

RSpec.configure do |config| 
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
