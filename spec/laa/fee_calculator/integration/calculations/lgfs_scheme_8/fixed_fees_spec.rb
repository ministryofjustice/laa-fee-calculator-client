# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe 'calculate' do
    context 'with LGFS scheme 8' do
      let(:fee_scheme) { client.fee_schemes(type: 'LGFS', case_date: '2018-01-01') }

      context 'with Fixed fees' do
        context 'with Appeal againt conviction' do
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
            expect(calculate).to eql fixed_amount
          end

          describe 'units' do
            [1, 10, 100].each do |quantity|
              context "with quantity of #{quantity}" do
                let(:quantity) { quantity }

                it 'returns fixed amount' do
                  expect(calculate).to eql fixed_amount
                end
              end
            end
          end

          describe 'modifier-types' do
            describe 'number_of_defendants' do
              [1, 10].each do |number_of_defendants|
                context "with #{number_of_defendants} defendants" do
                  let(:number_of_defendants) { number_of_defendants }

                  it 'returns fixed amount' do
                    expect(calculate).to eql fixed_amount
                  end
                end
              end
            end

            describe 'number_of_cases' do
              [1, 10].each do |number_of_cases|
                context "with #{number_of_cases} cases" do
                  let(:number_of_cases) { number_of_cases }

                  it 'returns fixed amount' do
                    expect(calculate).to eql fixed_amount
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
