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
        @prices_data = "#{@base_url}prices/"
        @prices_pages = []
      end

      def each(&block)
        prices.each(&block)
      end

      def size
        @size ||= prices_data(0)['count']
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
        size.times.lazy.map { |i| prices_pages(i / 100)[i % 100] }
      end

      def prices_pages(page)
        @prices_pages[page] ||= prices_data(page)['results'].map { |data| Price.new(**data) }
      end

      def prices_data(page)
        if @prices_data.is_a?(String)
          @prices_data = [api_request(@prices_data)]
          @prices_data += Array.new((@prices_data[0]['count'] / 100) - 1) { nil } if @prices_data[0]['count'] > 100
        end

        @prices_data[page] ||= api_request(prices_data(page - 1)['next'])
      end

      def api_request(url)
        JSON.parse(Connection.instance.get(url, @params).body)
      end
    end
  end
end
