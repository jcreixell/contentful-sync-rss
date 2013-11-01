module ContentfulSyncRss
  class RequestHandler

    def self.request(url, access_token)
      response = nil
      items = []
      begin
        content = EM::HttpRequest.new(url).get query: {'access_token' => access_token}
        if content.response_header.status == 200
          response = JSON.parse(content.response)
          items += response['items']
        else
          raise Errors::SyncApiError
        end
      end while url = response['nextPageUrl']

      Response.new(items, response['nextSyncUrl'])
    end

  end
end
