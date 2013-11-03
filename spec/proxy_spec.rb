require 'spec_helper'

module ContentfulSyncRss
  describe Proxy do

    let(:client_id) { '300f33c4a33b9c23dd9ab810bd297929' }
    let(:access_token) { "b4c0n73n7fu1" }
    let(:space) { "cfexampleapi" }
    let(:url) { "https://cdn.contentful.com/spaces/#{space}/sync" }
    let(:response_body) { File.read("./spec/support/json/response.json") }

    before(:each) do
      Client.new(client_id, space, access_token, nil).save($redis)

      stub_request(:get, url).
        with(:query => {'initial' => 'true', 'access_token' => access_token}).
        to_return(body: response_body, status: 200)
    end

    describe "authentication" do
      it "requires a Client-Id header" do
        with_api(Proxy) do
          get_request path: '/' do |content|
            content.response_header.status.should == 400
            content.response.should == %Q{{"error":"Required header: Client-Id."}}
          end
        end
      end

      context "with invalid client id" do
        it "does not authenticate the client" do
          with_api(Proxy) do
            get_request path: '/', head: {"Client-Id" => "INVALID ID"} do |content|
              content.response_header.status.should == 401
              content.response.should == 'Authentication failed.'
            end
          end
        end
      end

      describe "response" do
        it "mirrors the contentful sync API in RSS format" do
          with_api(Proxy) do
            get_request path: '/', head: {"Client-Id" => client_id} do |content|
              content.response_header.status.should == 200
              content.response.should == File.read("./spec/support/rss/response.rss")
            end
          end
        end

        it "stores the next_sync_url for the client" do
          with_api(Proxy) do
            get_request path: '/', head: {"Client-Id" => client_id} do |content|
              Client.find($redis, client_id).next_sync_url.should == JSON.parse(response_body)['nextSyncUrl']
            end
          end
        end

        it "uses the next_sync_url in subsequent requests" do
          with_api(Proxy) do
            get_request path: '/', head: {"Client-Id" => client_id}
            get_request path: '/', head: {"Client-Id" => client_id} do |content|
              content.response_header.status.should == 200
              content.response.should == File.read("./spec/support/rss/empty_response.rss")
            end
          end
        end

        context "an error occurs while acessing to the Sync API" do
          before(:each) do
            stub_request(:get, url).
              with(:query => {'initial' => 'true', 'access_token' => access_token}).
              to_return(status: 500)
          end

          it "returns an error" do
            with_api(Proxy) do
              get_request path: '/', head: {"Client-Id" => client_id} do |content|
                content.response_header.status.should == 500
              end
            end
          end

          it "does not store the next_sync_url" do
            with_api(Proxy) do
              get_request path: '/', head: {"Client-Id" => client_id} do |content|
                $redis.get("clients:#{client_id}:next_sync_url").should be_blank
              end
            end
          end
        end
      end
    end

  end
end
