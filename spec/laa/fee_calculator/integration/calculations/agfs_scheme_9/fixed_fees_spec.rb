# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe 'calculate' do
    context 'AGFS scheme 9' do
      let(:fee_scheme) { client.fee_schemes(type: 'AGFS', case_date: '2018-01-01') }

      context 'Fixed fees' do
        context 'Appeal againt conviction' do
          subject(:calculate) do
            fee_scheme.calculate(
              scenario: scenario,
              advocate_type: advocate_type,
              offence_class: offence_class,
              fee_type_code: fee_type_code,
              day: quantity,
              number_of_cases: number_of_cases,
              number_of_defendants: number_of_defendants
            )
          end

          let(:scenario) { 5 } # Appeal against convicition
          let(:advocate_type) { 'JRALONE' }
          let(:offence_class) { 'E' }
          let(:fee_type_code) { 'AGFS_APPEAL_CON' }
          let(:quantity) { 1 }
          let(:number_of_cases) { 1 }
          let(:number_of_defendants) { 1 }

          it 'returns calculated value' do
            expect(calculate).to be 130.0
          end

          context 'advocate_types' do
            let(:quantity) { 1 }

            context 'Junior alone' do
              let(:advocate_type) { 'JRALONE' }

              it { is_expected.to be(130.0) }
            end

            context 'Led junior' do
              let(:advocate_type) { 'LEDJR' }

              it { is_expected.to be(130.0) }
            end

            context 'Lead junior' do
              let(:advocate_type) { 'LEADJR' }

              it { is_expected.to be(195.0) }
            end

            context 'QC' do
              let(:advocate_type) { 'QC' }

              it { is_expected.to be(260.0) }
            end

            context 'INVALID' do
              let(:advocate_type) { 'INVALID' }

              it 'raises ResponseError' do
                expect { calculate }.to raise_client_error(described_class::ResponseError, /not a valid .*advocate/i)
              end
            end
          end

          context 'units' do
            context 'limit of 1 to 30' do
              [1, 30, 31].each do |quantity|
                context "for quantity of #{quantity}" do
                  let(:quantity) { quantity }

                  it { is_expected.to eql(quantity * 130.0) } if quantity.between?(1, 30)
                  it { is_expected.to be(3900.0) } if quantity > 30
                end
              end
            end
          end

          context 'modifier-types' do
            let(:quantity) { 1 }

            # NOTE: adds 20% to the unit cost per additional defendant
            # i.e. fee_per_unit + (fee_per_unit * (0.2 * (number_of_defendants-1)))
            #
            context 'number_of_defendants' do
              let(:advocate_type) { 'JRALONE' }
              let(:fee_per_unit) { 130.0 }
              let(:amount) do
                fee_per_unit + (fee_per_unit * (0.2 * (number_of_defendants - 1)))
              end

              context 'defendant 2+ carry a 20% uplift per defendant' do
                [1, 2, 3, 4, 5, 10, 100].each do |number_of_defendants|
                  context "#{number_of_defendants} defendants" do
                    let(:number_of_defendants) { number_of_defendants }

                    it { is_expected.to eql amount }
                  end
                end
              end
            end

            # NOTE: adds 20% to the unit cost per additional case
            # i.e. fee_per_unit + (fee_per_unit * (0.2 * (number_of_cases-1)))
            #
            context 'number_of_cases' do
              let(:advocate_type) { 'JRALONE' }
              let(:fee_per_unit) { 130.0 }
              let(:amount) do
                fee_per_unit + (fee_per_unit * (0.2 * (number_of_cases - 1)))
              end

              context 'cases 2+ carry a 20% uplift per case' do
                [1, 2, 3, 4, 5, 10, 100].each do |number_of_cases|
                  context "#{number_of_cases} cases" do
                    let(:number_of_cases) { number_of_cases }

                    it { is_expected.to eql amount }
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
