module ContentfulSyncRss
  class Response

    attr_accessor :items, :next_sync_url

    def initialize(items, next_sync_url)
      @items = items
      @next_sync_url = next_sync_url
    end

  end
end
