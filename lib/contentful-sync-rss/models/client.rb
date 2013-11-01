module ContentfulSyncRss
  class Client

    attr_accessor :id, :space, :access_token, :next_sync_url

    def initialize(id, space, access_token, next_sync_url)
      @id = id
      @space = space
      @access_token = access_token
      @next_sync_url = next_sync_url
    end

    def self.find(db, id)
      begin
        @space = db.get "clients:#{id}:space"
        @access_token = db.get "clients:#{id}:access_token"
        @next_sync_url = db.get "clients:#{id}:next_sync_url"
      rescue StandardError
        raise Errors::DatabaseAccessError
      end

      raise Errors::ClientNotFound unless @space && @access_token
      new(id, @space, @access_token, @next_sync_url)
    end

    def save(db)
      begin
        db.set("clients:#{@id}:space", @space)
        db.set("clients:#{@id}:access_token", @access_token)
        db.set("clients:#{@id}:next_sync_url", @next_sync_url)
      rescue StandardError
        raise Errors::Persistence::DatabaseAccessError
      end
    end

  end
end
