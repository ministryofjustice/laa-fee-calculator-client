# frozen_string_literal: true

require 'laa/fee_calculator/version'
require 'laa/fee_calculator/configuration'
require 'laa/fee_calculator/connection'
require 'laa/fee_calculator/fee_scheme'
require 'laa/fee_calculator/calculator'
require 'laa/fee_calculator/client'

module LAA
  module FeeCalculator
    class << self
      def root
        spec = Gem::Specification.find_by_name("laa-fee-calculator-client")
        spec.gem_dir
      end

      def client
        Client.new
      end

      attr_writer :configuration
      def configuration
        @configuration ||= Configuration.new
      end
      alias config configuration

      def configure
        yield(configuration) if block_given?
        configuration
      end

      def reset
        @configuration = Configuration.new
      end
    end
  end
end
