require "addressable/uri"

module LAA
  module FeeCalculator
    class Client
      extend Forwardable

      attr_reader :connection
      alias conn connection

      attr_accessor :fee_scheme

      def_delegators :connection, :host, :url_prefix, :port, :get, :ping

      def initialize
        @connection = Connection.instance
      end

      def fee_schemes(id = nil, **options)
        uri = 'fee-schemes/'
        id ||= options.fetch(:id, nil)
        uri.concat(id.to_s, "/") if id
        uri = Addressable::URI.parse(uri)
        uri.query_values = options.reject { |k, _v| k.eql?(:id) }

        json = get(uri).body

        fstruct = JSON.parse(json, object_class: FeeScheme)
        return fstruct unless fstruct.respond_to?(:results)
        return fstruct.results.first if fstruct.results.size.eql?(1)
        fstruct.results
      rescue Faraday::ClientError => err
        # TODO: logging
      end
    end
  end
end
