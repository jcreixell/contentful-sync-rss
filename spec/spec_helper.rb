require 'goliath/test_helper'
require 'mock_redis'

$redis = MockRedis.new

class Goliath::Server
  def load_config(file = nil)
    config['redis'] = $redis
  end
end

RSpec.configure do |c| 
  c.include Goliath::TestHelper, :example_group => {
    :file_path => /spec/
  }
end
