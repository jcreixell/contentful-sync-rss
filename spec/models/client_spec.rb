require 'spec_helper'

module ContentfulSyncRss
  describe Client do

    let(:client_id) { '300f33c4a33b9c23dd9ab810bd297929' }
    let(:access_token) { "b4c0n73n7fu1" }
    let(:space) { "cfexampleapi" }
    let(:next_sync_url) { "https://cdn.contentful.com/spaces/mlkty80quhya/sync?sync_token=token" }

    describe "find" do
      before(:each) do
        $redis.set("clients:#{client_id}:access_token", access_token)
        $redis.set("clients:#{client_id}:space", space)
        $redis.set("clients:#{client_id}:next_sync_url", next_sync_url)
      end

      it "finds a client based on a given id" do
        client = Client.find($redis, client_id)
        client.access_token.should == access_token
        client.space.should == space
        client.next_sync_url.should == next_sync_url
      end

      context "with non existing client" do
        it "raises an exception" do
          expect { Client.find($redis, "invalid_id") }.to raise_error Errors::ClientNotFound
        end
      end

      context "with invalid client" do
        before(:each) do
          $redis.del("clients:#{client_id}:space")
        end

        it "raises an exception" do
          expect { Client.find($redis, "invalid_id") }.to raise_error Errors::ClientNotFound
        end
      end
    end

    describe "save" do
      let(:client) { Client.new(client_id, space, access_token, next_sync_url) }

      it "saves the client attributes to the database" do
        client.save($redis)
        $redis.get("clients:#{client_id}:access_token").should == access_token
        $redis.get("clients:#{client_id}:space").should == space
        $redis.get("clients:#{client_id}:next_sync_url").should == next_sync_url 
      end
    end

  end
end
