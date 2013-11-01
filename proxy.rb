require_relative 'lib/contentful-sync-rss'

module ContentfulSyncRss
  class Proxy < Goliath::API

    use Goliath::Rack::Render
    include Goliath::Rack::Templates

    def on_headers(env, headers)
      if !env['HTTP_CLIENT_ID']
        raise Goliath::Validation::Error.new(
          400, "Required header: Client-Id.")
      end
    end

    def render_output(format, items)
      case format
      when :rss
        builder(:rss, locals: {items: items})
      else
        raise Errors::UnsupportedFormat
      end
    end

    def response(env)
      begin
        client = Client.find(redis, env['HTTP_CLIENT_ID'])
      rescue Errors::ClientNotFound
        return [401, {}, "Authentication failed."]
      end

      url = if client.next_sync_url.nil?
        "https://cdn.contentful.com/spaces/#{client.space}/sync?initial=true"
      else
        client.next_sync_url
      end

      response = RequestHandler.request(url, client.access_token)
      output = render_output(:rss, response.items)

      client.next_sync_url = response.next_sync_url
      client.save(redis)

      [200, {}, output]
    end

  end
end
