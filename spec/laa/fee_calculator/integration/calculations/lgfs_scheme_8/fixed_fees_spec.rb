# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe 'calculate' do
    context 'LGFS scheme 8' do
      let(:fee_scheme) { client.fee_schemes(type: 'LGFS', case_date: '2018-01-01') }

      context 'Fixed fees' do
        context 'Appeal againt conviction' do
          subject(:calculate) do
            fee_scheme.calculate(
              scenario: scenario,
              offence_class: offence_class,
              fee_type_code: fee_type_code,
              day: quantity,
              number_of_cases: number_of_cases,
              number_of_defendants: number_of_defendants
            )
          end

          let(:scenario) { 5 } # Appeal against convicition
          let(:offence_class) { 'E' }
          let(:fee_type_code) { 'LIT_FEE' }
          let(:quantity) { 1 }
          let(:number_of_cases) { 1 }
          let(:number_of_defendants) { 1 }
          let(:fixed_amount) { 349.47 }

          it 'returns calculated value' do
            is_expected.to eql fixed_amount
          end

          context 'units' do
            [1, 10, 100].each do |quantity|
              context "for quantity of #{quantity}" do
                let(:quantity) { quantity }
                it 'returns fixed amount' do
                  is_expected.to eql fixed_amount
                end
              end
            end
          end

          context 'modifier-types' do
            context 'number_of_defendants' do
              [1, 10].each do |number_of_defendants|
                context "#{number_of_defendants} defendants" do
                  let(:number_of_defendants) { number_of_defendants }
                  it 'returns fixed amount' do
                    is_expected.to eql fixed_amount
                  end
                end
              end
            end

            context 'number_of_cases' do
              [1, 10].each do |number_of_cases|
                context "#{number_of_cases} cases" do
                  let(:number_of_cases) { number_of_cases }
                  it 'returns fixed amount' do
                    is_expected.to eql fixed_amount
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
