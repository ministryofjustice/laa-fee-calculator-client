require 'laa/fee_calculator/version'
# require 'laa/fee_calculator/configuration'
require 'laa/fee_calculator/connection'
require 'laa/fee_calculator/client'
# require 'laa/fee_calculator/errors'

module LAA
  module FeeCalculator
    USER_AGENT = "LAA-FeeCalculator/#{VERSION}"

    def self.client
      Client.new
    end
  end
end
