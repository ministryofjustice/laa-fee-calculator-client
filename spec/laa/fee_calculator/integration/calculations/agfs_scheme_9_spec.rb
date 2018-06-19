# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe 'calculate' do
    context 'AGFS scheme 9' do
      let(:fee_scheme) { client.fee_schemes(supplier_type: 'ADVOCATE', case_date: '2018-01-01') }

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
            is_expected.to eql 130.0
          end

          context 'advocate_types' do
            let(:quantity) { 1 }
            context 'Junior alone' do
              let(:advocate_type) { 'JRALONE' }
              it { is_expected.to eql(130.0) }
            end

            context 'Led junior' do
              let(:advocate_type) { 'LEDJR' }
              it { is_expected.to eql(130.0) }
            end

            context 'Lead junior' do
              let(:advocate_type) { 'LEADJR' }
              it { is_expected.to eql(195.0) }
            end

            context 'QC' do
              let(:advocate_type) { 'QC' }
              it { is_expected.to eql(260.0) }
            end

            context 'INVALID' do
              let(:advocate_type) { 'INVALID' }
              it { is_expected.to be_nil }
            end
          end

          context 'units' do
            context 'limit of 1 to 30' do
              [1, 30, 31].each do |quantity|
                context "for quantity of #{quantity}" do
                  let(:quantity) { quantity }
                  it { is_expected.to eql(quantity * 130.0) } if quantity.between?(1, 30)
                  it { is_expected.to eql(3900.0) } if quantity > 30
                end
              end
            end
          end

          context 'modifier-types' do
            context 'number of defendants' do
              let(:unit_cost) { 130.0 }
              let(:quantity) { 1 }

              context "defendants 2 to 4 carry a 20\% uplift per unit" do
                context '2 defendants' do
                  let(:number_of_defendants) { 2 }
                  it { is_expected.to eql 156.0 }
                end

                context '4 defedants' do
                  let(:number_of_defendants) { 4 }
                  it { is_expected.to eql 208.0 }
                end
              end

              context "defendants 5+ carry a 30\% uplift per unit" do
                context '5 defedants' do
                  let(:number_of_defendants) { 5 }
                  it { is_expected.to eql 247.0 }
                end
              end

              context 'no upper limit' do
                context '1000 defendants' do
                  let(:number_of_defendants) { 1000 }
                  it { is_expected.to be > 30_000 }
                end
              end
            end
          end
        end
      end
    end
  end
end
