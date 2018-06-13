require 'laa/fee_calculator/has_many_result'

module LAA
  module FeeCalculator
    class FeeScheme < OpenStruct
      include HasManyResult
      extend Forwardable
      def_delegators :connection, :get

      has_many_results :advocate_types

      # def advocate_types
      #   uri = Addressable::URI.parse("fee-schemes/#{self.id}/advocate-types/")
      #   json = get(uri).body
      #   ostruct = JSON.parse(json, object_class: OpenStruct)
      #   ostruct.results
      # end

      private

      def connection
        @connection ||= Connection.instance
      end
    end
  end
end