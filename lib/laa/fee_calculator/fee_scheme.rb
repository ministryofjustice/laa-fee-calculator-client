# frozen_string_literal: true

require 'laa/fee_calculator/has_manyable'
require 'laa/fee_calculator/prices_collection'

module LAA
  module FeeCalculator
    class FeeScheme < OpenStruct
      include HasManyable
      extend Forwardable
      def_delegators :connection, :get

      has_many :advocate_types
      has_many :scenarios
      has_many :offence_classes
      has_many :fee_types
      has_many :units
      has_many :modifier_types

      def calculate(**options)
        yield options if block_given?
        LAA::FeeCalculator::Calculator.new(id, options).call
      end

      def prices(price_id = nil, **kwargs)
        price_id ||= kwargs[:id]
        return Price.find(price_id, base_uri: base_url) if price_id

        PricesCollection.new(fee_scheme: self, base_url: base_url, **kwargs)
      end

      private

      def connection
        @connection ||= Connection.instance
      end

      def base_url
        @base_url ||= "fee-schemes/#{id}/"
      end
    end
  end
end
