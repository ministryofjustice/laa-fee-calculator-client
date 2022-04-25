# frozen_string_literal: true

require 'csv'

module Helpers
  module Regulations
    def agfs_scheme_9_trial_fees_and_uplifts(**options)
      return filtered(@trial_fees_and_uplifts, options) unless @trial_fees_and_uplifts.nil?

      file = File.join(
        LAA::FeeCalculator.root, 'spec', 'fixtures', 'agfs_scheme_9_graduated_fees_and_uplifts_for_trials.csv'
      )
      data = CSV.read(file, encoding: 'UTF-8', headers: true, header_converters: :symbol, converters: :all)
      @trial_fees_and_uplifts = data.map(&:to_hash)
      filtered(@trial_fees_and_uplifts, options)
    end

    def filtered(hash, options)
      return hash unless options

      hash.select do |row|
        options.map { |attr, val| row[attr].eql?(val) }.all?
      end
    end
  end
end
