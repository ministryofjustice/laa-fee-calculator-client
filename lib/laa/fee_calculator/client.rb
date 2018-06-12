require 'laa/fee_calculator/has_many_result'

module LAA
  module FeeCalculator
    class Client
      include HasManyResult
      extend Forwardable

      attr_reader :connection
      alias conn connection

      attr_accessor :fee_scheme

      def_delegators :connection, :host, :url_prefix, :port, :get, :ping

      has_many_results :advocate_types

      def initialize
        @connection = Connection.instance
      end

      def fee_schemes(id = nil)
        json = get("fee-schemes/").body
        ostruct = JSON.parse(json, object_class: OpenStruct)
        return ostruct.results unless id
        ostruct.results.find { |result| result.id.eql?(id) }
      end
    end
  end
end
