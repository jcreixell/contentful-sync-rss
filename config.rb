config['redis'] = EM::Synchrony::ConnectionPool.new size: 2 do
  Redis.new
end
