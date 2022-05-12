# frozen_string_literal: true

require 'laa/fee_calculator/base_field'

module LAA
  module FeeCalculator
    class Price
      ATTRIBUTES = %i[
        id scheme scenario advocate_type fee_type offence_class unit fee_per_unit fixed_fee limit_from limit_to
      ].freeze

      include BaseField
    end
  end
end
