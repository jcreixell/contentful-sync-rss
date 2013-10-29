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
    # TODO: Refactor with client model + custom validation
    base_key = "clients:#{env['HTTP_CLIENT_ID']}"
    space = redis.get "#{base_key}:space"
    api_token = redis.get "#{base_key}:api_token"
    next_sync_url = redis.get "#{base_key}:next_sync_url"

    unless space && api_token
      #TODO: make consistent with validation errors
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
      content = EM::HttpRequest.new(url).get query: {'access_token' => api_token}
      logger.info content.response
      if content.response_header.status == 200
        response = JSON.parse(content.response)
        logger.info "Received #{content.response_header.status} from Contentful"
        items += response['items']
      else
        raise
      end

    end while url = response['nextPageUrl']

    rss = builder(:rss, locals: {items: items})

    if response['nextSyncUrl']
      redis.set("#{base_key}:next_sync_url", response['nextSyncUrl'])
    end

    [200, {}, rss]
  end

end
