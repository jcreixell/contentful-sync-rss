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
    WebMock.allow_net_connect!
  end
end
