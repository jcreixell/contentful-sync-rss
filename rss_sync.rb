require 'goliath'
require 'em-synchrony/em-http'
require 'json'

class RssSync < Goliath::API
  use Goliath::Rack::Render
  include Goliath::Rack::Templates

  def on_headers(env, headers)
    if env['HTTP_CLIENT_ID'].nil?
      raise Goliath::Validation::Error.new(
        400, "Required header: Client-Id.")
    end
  end

  def response(env)
    client_id = env['HTTP_CLIENT_ID']

    space = redis.get "clients:#{client_id}:space"
    access_token = redis.get "clients:#{client_id}:access_token"
    next_sync_url = redis.get "clients:#{client_id}:next_sync_url"

    unless space && access_token
      return [401, {}, "Authentication failed."]
    end

    url = if next_sync_url.nil?
      "https://cdn.contentful.com/spaces/#{space}/sync?initial=true"
    else
      next_sync_url
    end

    items = []
    response = nil
    begin
      content = EM::HttpRequest.new(url).get query: {'access_token' => access_token}
      if content.response_header.status == 200
        logger.info "Received #{content.response_header.status} from Contentful"
        response = JSON.parse(content.response)
        items += response['items']
      else
        raise
      end
    end while url = response['nextPageUrl']

    rss = builder(:rss, locals: {items: items})

    if response['nextSyncUrl']
      redis.set("clients:#{client_id}:next_sync_url", response['nextSyncUrl'])
    end

    [200, {}, rss]
  end

end
