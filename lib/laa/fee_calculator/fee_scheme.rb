# frozen_string_literal: true

require 'laa/fee_calculator/has_manyable'
require 'ostruct'

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
      has_many :prices

      def calculate(**options)
        yield options if block_given?
        LAA::FeeCalculator::Calculator.new(id, options).call
      end

      private

      def connection
        @connection ||= Connection.instance
      end
    end
  end
end
