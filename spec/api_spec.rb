require_relative 'spec_helper'
require_relative '../rss_sync'

describe RssSync do
  let(:client_id) { '300f33c4a33b9c23dd9ab810bd297929' }
  let(:access_token) { "b4c0n73n7fu1" }
  let(:space) { "cfexampleapi" }
  let(:response_body) { File.read("./spec/support/response.json") }

  before(:each) do
    $redis.set("clients:#{client_id}:api_token", access_token)
    $redis.set("clients:#{client_id}:space", space)
    $redis.set("clients:#{client_id}:next_sync_url", nil)

    stub_request(:any, "https://cdn.contentful.com/spaces/#{space}/sync").
      to_return(body: response_body, status: 200)
  end

  describe "authentication" do

    it "requires a Client-Id header" do
      with_api(RssSync) do
        get_request path: '/' do |rss_sync|
          rss_sync.response_header.status.should == 400
          rss_sync.response.should == %Q{{"error":"Required header: Client-Id."}}
        end
      end
    end

    context "with invalid client id" do
      it "does not authenticate the client" do
        with_api(RssSync) do
          get_request path: '/', head: {"Client-Id" => "INVALID ID"} do |rss_sync|
            rss_sync.response_header.status.should == 401
            rss_sync.response.should == 'Authentication failed.'
          end
        end
      end
    end

  end
end
