# frozen_string_literal: true

require 'laa/fee_calculator/price'

module LAA
  module FeeCalculator
    class PricesCollection
      include Enumerable

      def initialize(fee_scheme:, base_url: '', **kwargs)
        @fee_scheme = fee_scheme
        @base_url = base_url
        @params = kwargs
        @prices_url = "#{@base_url}prices/"
      end

      def each(&block)
        prices.each(&block)
      end

      def size
        prices.count
      end

      def last
        prices.last
      end

      def find_by(**options)
        prices.find do |price|
          options.map { |k, v| price[k].eql?(v) }.all?
        end
      end

      private

      def prices
        @prices ||= prices_data['results'].map { |p| Price.new(**p) }
      end

      def prices_data
        @prices_data ||= JSON.parse(Connection.instance.get(@prices_url, @params).body)
      end
    end
  end
end
