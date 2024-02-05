# frozen_string_literal: true

module LAA
  module FeeCalculator
    class Calculator
      extend Forwardable
      def_delegators :connection, :get

      def initialize(scheme_pk, options)
        @uri = "fee-schemes/#{scheme_pk}/calculate/"
        @filtered_params = options.except(:id)
      end

      def call
        json = get(@uri, @filtered_params).body
        JSON.parse(json)['amount']
      end

      private

      def connection
        @connection ||= Connection.instance
      end
    end
  end
end
