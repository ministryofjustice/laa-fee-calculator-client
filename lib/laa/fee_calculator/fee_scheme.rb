require 'laa/fee_calculator/has_manyable'

module LAA
  module FeeCalculator
    class FeeScheme < OpenStruct
      include HasManyable
      extend Forwardable
      def_delegators :connection, :get

      has_many :advocate_types

      private

      def connection
        @connection ||= Connection.instance
      end
    end
  end
end