# frozen_string_literal: true

module LAA
  module FeeCalculator
    class Calculator
      extend Forwardable
      def_delegators :connection, :get

      attr_reader :scheme_pk, :options

      def initialize(scheme_pk, options)
        @scheme_pk = scheme_pk
        @options = options
      end

      def call
        uri = "fee-schemes/#{scheme_pk}/calculate/"
        uri = Addressable::URI.parse(uri)
        uri.query_values = options.except(:id)
        json = get(uri).body
        JSON.parse(json)['amount']
      rescue Faraday::ClientError => err
        # TODO: logging
      end

      private

      def connection
        @connection ||= Connection.instance
      end
    end
  end
end
