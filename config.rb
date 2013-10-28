if Goliath.env?(:production)
  uri = URI.parse(ENV["REDISTOGO_URL"])
  config['redis'] = EM::Synchrony::ConnectionPool.new size: 2 do
    Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end
else
  config['redis'] = EM::Synchrony::ConnectionPool.new size: 2 do
    Redis.new
  end
end
