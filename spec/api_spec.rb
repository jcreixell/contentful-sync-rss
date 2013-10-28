require_relative 'spec_helper'
require_relative '../rss_sync'

describe RssSync do
  it "responds to heartbeat" do
    with_api(RssSync) do
      get_request path: '/' do |api|
        api.response.should == 'OK'
      end
    end
  end

  it "requires a client_id param"

  it "can set and retrieve data" do
    with_api(RssSync) do
      get_request path: '/bar' do |api|
        api.response.should == ''
      end
    end

    with_api(RssSync) do
      put_request path: '/bar?value=foo' do |api|
        api.response.should == 'OK'
      end
    end

    with_api(RssSync) do
      get_request path: '/bar' do |api|
        api.response.should == 'foo'
      end
    end
  end
end
