require 'spec_helper'

module ContentfulSyncRss
  describe RequestHandler do
    describe "request" do

      let(:access_token) { "b4c0n73n7fu1" }
      let(:space) { "cfexampleapi" }
      let(:url) { "https://cdn.contentful.com/spaces/#{space}/sync" }
      let(:response_body) { File.read("./spec/support/json/response.json") }

      before(:each) do
        stub_request(:get, url).
          with(:query => {'access_token' => access_token}).
          to_return(body: response_body, status: 200)
      end

      it "returns a response object" do
        async do
          response = RequestHandler.request(url, access_token)
          response.items.should == JSON.parse(response_body)['items']
          response.next_sync_url.should == JSON.parse(response_body)['nextSyncUrl']
        end
      end

      context "with pagination" do
        let(:response_body_page1) { File.read("./spec/support/json/multipage_response_page1.json") }
        let(:response_body_page2) { File.read("./spec/support/json/multipage_response_page2.json") }

        before(:each) do
          stub_request(:get, url).
            with(:query => {'access_token' => access_token}).
            to_return(body: response_body_page1, status: 200)

          stub_request(:get, url).
            with(:query => {'sync_token' => 'nextpagetoken', 'access_token' => access_token}).
            to_return(body: response_body_page2, status: 200)
        end

        it "collects the data from all the pages into a single response object" do
          async do
            response = RequestHandler.request(url, access_token)
            response.items.should == JSON.parse(response_body_page1)['items'] + JSON.parse(response_body_page2)['items']
          end
        end

        it "sets the next_sync_url" do
          async do
            response = RequestHandler.request(url, access_token)
            response.next_sync_url.should == JSON.parse(response_body_page2)['nextSyncUrl']
          end
        end
      end

      context "an error occurs while accessing to the API" do
        before(:each) do
          stub_request(:get, url).
            with(:query => {'access_token' => access_token}).
            to_return(status: 500)
        end

        it "returns an error" do
          async do
            expect { RequestHandler.request(url, access_token) }.to raise_error Errors::SyncApiError
          end
        end
      end

    end
  end
end
