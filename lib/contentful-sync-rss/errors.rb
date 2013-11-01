module ContentfulSyncRss
  module Errors

    class Base < ::StandardError; end

    class SyncApiError < Base; end

    class DatabaseAccessError < Base; end

    class ClientNotFound < Base; end

  end
end
