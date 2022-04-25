# frozen_string_literal: true

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
        uri = fee_schemes_uri(id || options[:id])
        filtered_params = options.reject { |k, _| k.eql?(:id) }
        # Ruby 3.0+; filtered_params = options.except(:id)

        json = get(uri, filtered_params).body

        fstruct = JSON.parse(json, object_class: FeeScheme)
        return fstruct unless fstruct.respond_to?(:results)
        return fstruct.results.first if fstruct.results.size.eql?(1)

        fstruct.results
      end

      private

      def fee_schemes_uri(id)
        return "fee-schemes/#{id}/" if id

        'fee-schemes/'
      end
    end
  end
end
