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
        uri.query_values = options.reject { |k, _v| k.eql?(:id) }
        json = get(uri).body
        JSON.parse(json)['amount']
      rescue Faraday::ClientError => err
        # TODO: logging
      end

      private

      def uri
        @uri ||= Addressable::URI.parse("fee-schemes/#{scheme_pk}/calculate/")
      end

      def connection
        @connection ||= Connection.instance
      end
    end
  end
end
