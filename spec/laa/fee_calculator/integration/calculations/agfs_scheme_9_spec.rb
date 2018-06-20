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
            let(:quantity) { 1 }

            # NOTE: adds 20% for defendant 2 to 4 and 30% for defendant 5+ to the unit cost
            # i.e. unit_cost + (unit_cost * (0.2 * [number_of_defendants-1,3].min) + (0.3 * [number_of_defendants-4,0].min))
            #
            context 'number of defendants' do
              context 'defendant 1 carries no uplift' do
                let(:number_of_defendants) { 1 }
                it { is_expected.to eql 130.0 }
              end

              context "defendants 2 to 4 carry a 20\% uplift per defendant" do
                context '2 defendants' do
                  let(:number_of_defendants) { 2 }
                  it { is_expected.to eql 156.0 }
                end

                context '4 defendants' do
                  let(:number_of_defendants) { 4 }
                  it { is_expected.to eql 208.0 }
                end
              end

              context "defendants 5+ carry a 30\% uplift per defendant" do
                context '5 defendants' do
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

            context 'number_of_cases' do
              # NOTE: adds 20% to the unit cost per additional case
              # i.e. unit_cost + (unit_cost*(0.2*(number_of_cases-1)))
              #
              context "cases 2+ carry a 20\% uplift per case" do
                [1, 2, 3, 4, 5, 10, 100].each do |number_of_cases|
                  context "#{number_of_cases} cases" do
                    let(:amount) { 130 + (130 * (0.2 * (number_of_cases - 1))) }
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
