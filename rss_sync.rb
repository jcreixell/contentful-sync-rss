require 'goliath'
require 'em-synchrony/em-http'
require 'json'

class RssSync < Goliath::API
  use Goliath::Rack::Render
  use Goliath::Rack::Heartbeat, path: '/'
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

    content = if next_sync_url.nil?
      EM::HttpRequest.new("https://cdn.contentful.com/spaces/#{space}/sync?initial=true&access_token=#{api_token}").get
    else
      EM::HttpRequest.new(next_sync_url).get
    end

    logger.info "Received #{content.response_header.status} from Contentful"

    if content.response_header.status == 200
      # TODO: iterate through pages and store next sync url
      items = JSON.parse(content.response)['items']
      logger.info items
      logger.info builder(:rss, locals: {items: items})
    else
      # TODO: handle exception
    end

    [200, {}, content.response]
  end

end
