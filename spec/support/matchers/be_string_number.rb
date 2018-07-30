# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'

RSpec::Matchers.define :be_string_number do
  match do |actual|
    begin
      BigDecimal(actual)
    rescue StandardError
      false
    end
  end

  description do
    'be convertable to big decimal'
  end
end
